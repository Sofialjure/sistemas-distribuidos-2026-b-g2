package co.edu.corhuila.telemedia.documentgeneration.app;

import static org.assertj.core.api.Assertions.assertThat;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;

/**
 * Story #149 (STRIDE S, risk 6): only the clients listed in GENERATION_SERVICE_CLIENTS may
 * request a PDF with a SERVICE token. Runs against a running document-generation-api.
 *
 * DOC_API_URL           e.g. http://document-generation-api:8080
 * OTHER_SERVICE_TOKEN   RS256 token, role SERVICE, sub not in the list (e.g. notifications)
 */
@EnabledIfEnvironmentVariable(named = "OTHER_SERVICE_TOKEN", matches = ".+")
class GenerateDocumentAuthorizationTest {

    private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
    private final String baseUrl = System.getenv().getOrDefault("DOC_API_URL", "http://localhost:8080");

    @Test
    void aServiceThatIsNotTheWorkerCannotRequestAPdf() throws Exception {
        String body = """
                {"summaryId":"%s","patientId":"%s"}""".formatted(UUID.randomUUID(), UUID.randomUUID());

        HttpResponse<String> response = http.send(HttpRequest.newBuilder()
                        .uri(URI.create(baseUrl + "/api/documents/generate"))
                        .timeout(Duration.ofSeconds(10))
                        .header("Authorization", "Bearer " + System.getenv("OTHER_SERVICE_TOKEN"))
                        .header("Content-Type", "application/json")
                        .header("Idempotency-Key", "w13-negative-" + UUID.randomUUID())
                        .POST(HttpRequest.BodyPublishers.ofString(body))
                        .build(),
                HttpResponse.BodyHandlers.ofString());

        assertThat(response.statusCode()).isEqualTo(403);
        assertThat(response.body()).contains("\"error\"").contains("\"traceId\"");
    }
}
