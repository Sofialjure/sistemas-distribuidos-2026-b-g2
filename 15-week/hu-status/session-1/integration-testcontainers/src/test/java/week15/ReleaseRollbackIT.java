package week15;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.sql.Connection;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.testcontainers.containers.PostgreSQLContainer;

/**
 * Week 15 session 2 - rehearsal of the database part of the rollback plan of release 3.0.0, on
 * the real upgrade path: the database is first migrated with main (v2.0.0, -Dpm.db.main /
 * -Ddg.db.main), then upgraded with the release (qa), then rolled back with the counts the
 * rollback plans of the release PRs state, and upgraded again.
 */
class ReleaseRollbackIT {

    static final int PM_MAIN = 27, PM_RELEASE_CHANGESETS = 9;
    static final int DG_MAIN = 13, DG_RELEASE_CHANGESETS = 4;

    static PostgreSQLContainer<?> postgres() {
        return new PostgreSQLContainer<>(DomainDatabase.IMAGE)
                .withDatabaseName("telemed_ia").withUsername("postgres").withPassword("tc-admin-local-only");
    }

    @Test
    void documentGenerationGoesBackToV2AndForwardAgain() throws Exception {
        try (var pg = postgres()) {
            pg.start();
            var db = new DomainDatabase(pg, "document_generation", DomainDatabase.repository("dg.db.main"), false);
            db.bootstrap();
            db.update();
            assertEquals(DG_MAIN, db.appliedChangesets());
            db.withRepository(DomainDatabase.repository("dg.db.repo")).update();
            assertEquals(DG_MAIN + DG_RELEASE_CHANGESETS, db.appliedChangesets());
            db.rollback(DG_RELEASE_CHANGESETS);
            assertEquals(DG_MAIN, db.appliedChangesets());
            assertEquals(0, db.count("SELECT count(*) FROM information_schema.tables "
                    + "WHERE table_schema = 'document_generation' AND table_name = 'outbox_event'"));
            db.update();
            assertEquals(DG_MAIN + DG_RELEASE_CHANGESETS, db.appliedChangesets());
        }
    }

    @Test
    void professionalManagementGoesBackToV2WhileNoProfileWasCreatedOnTheRelease() throws Exception {
        try (var pg = postgres()) {
            pg.start();
            var db = new DomainDatabase(pg, "professional_management", DomainDatabase.repository("pm.db.main"), true);
            db.bootstrap();
            db.update();
            assertEquals(PM_MAIN, db.appliedChangesets());
            db.withRepository(DomainDatabase.repository("pm.db.repo")).update();
            assertEquals(PM_MAIN + PM_RELEASE_CHANGESETS, db.appliedChangesets());
            db.rollback(PM_RELEASE_CHANGESETS);
            assertEquals(PM_MAIN, db.appliedChangesets());
            db.update();
            assertEquals(PM_MAIN + PM_RELEASE_CHANGESETS, db.appliedChangesets());
        }
    }

    @Test
    void professionalManagementRefusesToGoBackOnceTheReleaseCreatedAProfile() throws Exception {
        try (var pg = postgres()) {
            pg.start();
            var db = new DomainDatabase(pg, "professional_management", DomainDatabase.repository("pm.db.main"), true);
            db.bootstrap();
            db.update();
            assertEquals(PM_MAIN, db.appliedChangesets());
            db.withRepository(DomainDatabase.repository("pm.db.repo")).update();
            try (Connection c = db.app()) {
                c.createStatement().executeUpdate("INSERT INTO professional (license_number, identity_user_id) VALUES ('RM-RB-1', '"
                        + UUID.randomUUID() + "')");
            }
            // ddl-alter-024 cannot map a database-generated UUID back to an integer id: it refuses
            assertThrows(Exception.class, () -> db.rollback(PM_RELEASE_CHANGESETS));
            // and the refusal leaves the release schema and the row in place
            assertEquals(1, db.count("SELECT count(*) FROM professional_management.professional"));
            assertEquals("uuid", stringOf(db, "SELECT data_type FROM information_schema.columns "
                    + "WHERE table_schema = 'professional_management' AND table_name = 'professional' AND column_name = 'id'"));
        }
    }

    private static String stringOf(DomainDatabase db, String sql) throws Exception {
        try (Connection c = db.admin(); var r = c.createStatement().executeQuery(sql)) {
            r.next();
            return r.getString(1);
        }
    }
}
