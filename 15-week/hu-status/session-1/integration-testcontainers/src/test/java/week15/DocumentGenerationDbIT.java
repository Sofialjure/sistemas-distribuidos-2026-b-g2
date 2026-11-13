package week15;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.sql.Connection;
import java.sql.PreparedStatement;
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

/** telemed-ia-document-generation-db against a real PostgreSQL 16 started by Testcontainers. */
@Testcontainers
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class DocumentGenerationDbIT {

    @Container
    static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>(DomainDatabase.IMAGE)
            .withDatabaseName("telemed_ia").withUsername("postgres").withPassword("tc-admin-local-only");

    static DomainDatabase db;

    @BeforeAll
    static void migrate() throws Exception {
        db = new DomainDatabase(POSTGRES, "document_generation",
                DomainDatabase.repository("dg.db.repo"), false);
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
    void theDocumentAndItsOutboxEventCommitTogether() throws Exception {
        UUID document = UUID.randomUUID();
        try (Connection c = db.app()) {
            c.setAutoCommit(false);
            insertDocument(c, document, "AVAILABLE", "patients/p/" + document + ".pdf", null);
            try (PreparedStatement p = c.prepareStatement(
                    "INSERT INTO outbox_event (aggregate_id, event_type, correlation_id, payload) "
                            + "VALUES (?, 'ConsultationPdfGenerated', 'tc-corr-1', '{\"documentId\":\"x\"}'::jsonb)")) {
                p.setObject(1, document);
                p.executeUpdate();
            }
            c.commit();
        }
        assertEquals(1, db.count("SELECT count(*) FROM document_generation.outbox_event WHERE aggregate_id = '" + document + "'"));
    }

    @Test
    @Order(3)
    void aRolledBackTransactionLeavesNeitherTheDocumentNorTheEvent() throws Exception {
        UUID document = UUID.randomUUID();
        try (Connection c = db.app()) {
            c.setAutoCommit(false);
            insertDocument(c, document, "PENDING", null, null);
            // the event violates its check, so the whole unit of work is undone
            SQLException e = assertThrows(SQLException.class, () -> {
                try (PreparedStatement p = c.prepareStatement(
                        "INSERT INTO outbox_event (aggregate_id, event_type, correlation_id, payload) "
                                + "VALUES (?, 'SomethingElse', 'tc-corr-2', '{}'::jsonb)")) {
                    p.setObject(1, document);
                    p.executeUpdate();
                }
            });
            assertEquals("23514", e.getSQLState());
            c.rollback();
        }
        assertEquals(0, db.count("SELECT count(*) FROM document_generation.consultation_document WHERE document_id = '" + document + "'"));
    }

    @Test
    @Order(4)
    void stateRulesAreEnforcedByTheSchema() {
        // AVAILABLE needs its storage reference; ERROR needs its message
        assertEquals("23514", assertThrows(SQLException.class, () -> {
            try (Connection c = db.app()) {
                insertDocument(c, UUID.randomUUID(), "AVAILABLE", null, null);
            }
        }).getSQLState());
        assertEquals("23514", assertThrows(SQLException.class, () -> {
            try (Connection c = db.app()) {
                insertDocument(c, UUID.randomUUID(), "ERROR", null, null);
            }
        }).getSQLState());
    }

    @Test
    @Order(5)
    void anIdempotencyKeyIsStoredOnce() throws Exception {
        String sql = "INSERT INTO idempotency_key (idempotency_key, request_hash) VALUES ('tc-key-0001', 'h1')";
        try (Connection c = db.app()) {
            c.createStatement().executeUpdate(sql);
            assertEquals("23505", assertThrows(SQLException.class, () -> c.createStatement().executeUpdate(sql)).getSQLState());
        }
    }

    @Test
    @Order(6)
    void theWholeSchemaRollsBackAndIsAppliedAgain() throws Exception {
        try (Connection c = db.app()) {
            c.createStatement().execute("DELETE FROM outbox_event");
            c.createStatement().execute("DELETE FROM idempotency_key");
            c.createStatement().execute("DELETE FROM consultation_document");
        }
        // Every changeset but ddl-schemas-001: in the shared instance the schema belongs to
        // telemed-ia-infra-postgres and it also holds the Liquibase control tables of the domain.
        db.rollback(db.appliedChangesets() - 1);
        assertEquals(1, db.appliedChangesets());
        assertEquals(0, db.tablesInSchema());
        db.update();
        assertEquals(db.expectedChangesets(), db.appliedChangesets());
    }

    private static void insertDocument(Connection c, UUID document, String status, String reference, String error)
            throws SQLException {
        try (PreparedStatement p = c.prepareStatement(
                "INSERT INTO consultation_document (document_id, summary_id, patient_id, format, status, storage_reference, "
                        + "error_message, generated_at) VALUES (?, ?, ?, 'PDF', ?, ?, ?, "
                        + "CASE WHEN ? = 'AVAILABLE' THEN now() END)")) {
            p.setObject(1, document);
            p.setObject(2, UUID.randomUUID());
            p.setObject(3, UUID.randomUUID());
            p.setString(4, status);
            p.setString(5, reference);
            p.setString(6, error);
            p.setString(7, status);
            p.executeUpdate();
        }
    }
}
