package week15;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

/** telemed-ia-professional-management-db against a real PostgreSQL 16 started by Testcontainers. */
@Testcontainers
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class ProfessionalManagementDbIT {

    @Container
    static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>(DomainDatabase.IMAGE)
            .withDatabaseName("telemed_ia").withUsername("postgres").withPassword("tc-admin-local-only");

    static DomainDatabase db;

    @BeforeAll
    static void migrate() throws Exception {
        db = new DomainDatabase(POSTGRES, "professional_management",
                DomainDatabase.repository("pm.db.repo"), true);
        db.bootstrap();
        db.update();
    }

    @Test
    @Order(1)
    void everyChangesetIsAppliedFromAnEmptyDatabase() throws Exception {
        assertEquals(db.expectedChangesets(), db.appliedChangesets());
    }

    @Test
    @Order(2)
    void aNewProfessionalGetsItsDefaults() throws Exception {
        try (Connection c = db.app(); PreparedStatement p = c.prepareStatement(
                "INSERT INTO professional (license_number, years_experience, identity_user_id) VALUES (?, 4, ?) "
                        + "RETURNING id, professional_type, status, created_at")) {
            p.setString(1, "RM-TC-0001");
            p.setObject(2, UUID.randomUUID());
            try (ResultSet r = p.executeQuery()) {
                r.next();
                assertNotNull(r.getObject("id", UUID.class));
                assertEquals("GENERAL_PRACTITIONER", r.getString("professional_type"));
                assertEquals("ACTIVE", r.getString("status"));
                assertNotNull(r.getTimestamp("created_at"));
            }
        }
    }

    @Test
    @Order(3)
    void aRepeatedLicenseIsRejectedByTheUniqueConstraint() {
        SQLException e = assertThrows(SQLException.class,
                () -> insert("RM-TC-0001", UUID.randomUUID(), "ACTIVE", 1));
        assertEquals("23505", e.getSQLState());
    }

    @Test
    @Order(4)
    void anUnknownStatusAndNegativeYearsAreRejectedByChecks() {
        assertEquals("23514", assertThrows(SQLException.class,
                () -> insert("RM-TC-0002", UUID.randomUUID(), "SUSPENDED", 1)).getSQLState());
        assertEquals("23514", assertThrows(SQLException.class,
                () -> insert("RM-TC-0003", UUID.randomUUID(), "ACTIVE", -1)).getSQLState());
    }

    @Test
    @Order(5)
    void theWholeSchemaRollsBackAndIsAppliedAgain() throws Exception {
        try (Connection c = db.app()) {
            c.createStatement().execute("DELETE FROM idempotency_key");
            c.createStatement().execute("DELETE FROM professional");
        }
        // Every changeset but ddl-schemas-001: in the shared instance the schema belongs to
        // telemed-ia-infra-postgres and it also holds the Liquibase control tables of the domain.
        db.rollback(db.appliedChangesets() - 1);
        assertEquals(1, db.appliedChangesets());
        assertEquals(0, db.tablesInSchema());
        db.update();
        assertEquals(db.expectedChangesets(), db.appliedChangesets());
    }

    private static void insert(String license, UUID account, String status, int years) throws SQLException {
        try (Connection c = db.app(); PreparedStatement p = c.prepareStatement(
                "INSERT INTO professional (license_number, years_experience, identity_user_id, status) VALUES (?, ?, ?, ?)")) {
            p.setString(1, license);
            p.setInt(2, years);
            p.setObject(3, account);
            p.setString(4, status);
            p.executeUpdate();
        }
    }
}
