package week15;

import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import liquibase.Contexts;
import liquibase.LabelExpression;
import liquibase.Liquibase;
import liquibase.database.Database;
import liquibase.database.DatabaseFactory;
import liquibase.database.jvm.JdbcConnection;
import liquibase.resource.DirectoryResourceAccessor;
import org.testcontainers.containers.PostgreSQLContainer;

/**
 * One domain of the shared PostgreSQL instance, bootstrapped as telemed-ia-infra-postgres does it
 * (postgres/init/01-instance.sh): application user, reader and writer roles, CREATE on the
 * database, schema owned by the application user and its search_path. The migrations are the
 * real changelog of the -db repository, run as the application user with the suffixed Liquibase
 * control tables, exactly like the migrator of the repository.
 */
final class DomainDatabase {

    static final String IMAGE = "postgres:16-alpine";

    private final PostgreSQLContainer<?> container;
    private final String schema;
    private final String appUser;
    private final String appPassword;
    private Path repository;
    private final boolean adminOption;

    DomainDatabase(PostgreSQLContainer<?> container, String schema, Path repository, boolean adminOption) {
        this.container = container;
        this.schema = schema;
        this.appUser = schema + "_app";
        this.appPassword = "tc-" + schema.replace('_', '-') + "-local-only";
        this.repository = repository;
        this.adminOption = adminOption;
    }

    static Path repository(String property) {
        String value = System.getProperty(property);
        if (value == null || value.isBlank() || value.startsWith("${")) {
            throw new IllegalStateException("set -D" + property + "=<path of the -db clone>");
        }
        Path path = Path.of(value);
        if (!Files.isRegularFile(path.resolve("changelog/changelog-master.yaml"))) {
            throw new IllegalStateException(path + " has no changelog/changelog-master.yaml");
        }
        return path;
    }

    /** The same database, migrated from now on with another checkout of the -db repository. */
    DomainDatabase withRepository(Path other) {
        this.repository = other;
        return this;
    }

    void bootstrap() throws SQLException {
        String grant = "GRANT " + schema + "_reader, " + schema + "_writer TO " + appUser
                + (adminOption ? " WITH ADMIN OPTION" : "");
        try (Connection c = admin(); Statement s = c.createStatement()) {
            s.execute("CREATE EXTENSION IF NOT EXISTS pgcrypto");
            s.execute("CREATE ROLE " + appUser + " LOGIN PASSWORD '" + appPassword + "'");
            s.execute("CREATE ROLE " + schema + "_reader NOLOGIN");
            s.execute("CREATE ROLE " + schema + "_writer NOLOGIN");
            s.execute(grant);
            s.execute("GRANT CREATE ON DATABASE " + container.getDatabaseName() + " TO " + appUser);
            s.execute("REVOKE CREATE ON SCHEMA public FROM " + appUser);
            s.execute("CREATE SCHEMA IF NOT EXISTS " + schema + " AUTHORIZATION " + appUser);
            s.execute("ALTER ROLE " + appUser + " SET search_path = " + schema);
        }
    }

    Connection admin() throws SQLException {
        return DriverManager.getConnection(container.getJdbcUrl(), container.getUsername(), container.getPassword());
    }

    Connection app() throws SQLException {
        return DriverManager.getConnection(container.getJdbcUrl(), appUser, appPassword);
    }

    int expectedChangesets() throws Exception {
        return Integer.parseInt(Files.readString(repository.resolve("changelog/expected-count.txt")).trim());
    }

    void update() throws Exception {
        try (Connection c = app()) {
            liquibase(c).update(new Contexts(), new LabelExpression());
        }
    }

    void rollback(int changesets) throws Exception {
        try (Connection c = app()) {
            liquibase(c).rollback(changesets, (String) null);
        }
    }

    int appliedChangesets() throws SQLException {
        return count("SELECT count(*) FROM " + schema + ".databasechangelog_" + schema);
    }

    int tablesInSchema() throws SQLException {
        return count("SELECT count(*) FROM information_schema.tables WHERE table_schema = '" + schema
                + "' AND table_name NOT LIKE 'databasechangelog%'");
    }

    int count(String sql) throws SQLException {
        try (Connection c = admin(); Statement s = c.createStatement(); ResultSet r = s.executeQuery(sql)) {
            r.next();
            return r.getInt(1);
        }
    }

    private Liquibase liquibase(Connection connection) throws Exception {
        Database database = DatabaseFactory.getInstance()
                .findCorrectDatabaseImplementation(new JdbcConnection(connection));
        database.setDatabaseChangeLogTableName("databasechangelog_" + schema);
        database.setDatabaseChangeLogLockTableName("databasechangeloglock_" + schema);
        database.setDefaultSchemaName(schema);
        database.setLiquibaseSchemaName(schema);
        return new Liquibase("changelog/changelog-master.yaml", new DirectoryResourceAccessor(repository), database);
    }
}
