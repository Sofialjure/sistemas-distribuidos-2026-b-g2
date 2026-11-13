## professional-management-api
| method | uri | status | requests | mean ms | max ms (recent window) |
|---|---|---|---|---|---|
| GET | /api/professionals | 200 | 39737 | 16.4 | 0.0 |
| POST | /internal/professionals | 201 | 5 | 114.2 | 0.0 |
| GET | UNKNOWN | 401 | 4 | 3.1 | 8.2 |
| PATCH | /api/professionals/{professionalId}/status | 403 | 3 | 7.6 | 3.4 |
| POST | /api/professionals/admin/register | 400 | 3 | 12.8 | 29.3 |
| GET | /api/professionals/me | 403 | 2 | 3.3 | 4.6 |
| PATCH | /api/professionals/{professionalId}/status | 200 | 2 | 25.1 | 0.0 |
| POST | /internal/professionals | 400 | 2 | 6.2 | 10.4 |
| POST | /api/professionals/admin/register | 403 | 2 | 5.5 | 6.5 |
| GET | /api/professionals/me | 200 | 1 | 189.3 | 0.0 |
| GET | /health | 200 | 1 | 95.3 | 0.0 |
| POST | /internal/professionals | 403 | 1 | 3.1 | 3.1 |
| POST | /api/professionals/admin/register | 503 | 1 | 105.8 | 0.0 |
| POST | /api/professionals/admin/register | 201 | 1 | 341.4 | 0.0 |
    professional_registrations_total{application="professional-management-api",outcome="created"} 1.0
    professional_registrations_total{application="professional-management-api",outcome="rejected"} 2.0
    professional_registrations_total{application="professional-management-api",outcome="unavailable"} 1.0
    professional_status_changes_total{application="professional-management-api",outcome="applied"} 2.0
    professional_status_changes_total{application="professional-management-api",outcome="rejected"} 3.0

## document-generation-api
| method | uri | status | requests | mean ms | max ms (recent window) |
|---|---|---|---|---|---|
| GET | /api/documents | 403 | 4 | 7.9 | 18.1 |
| POST | /api/documents/generate | 403 | 4 | 4.3 | 4.7 |
| GET | UNKNOWN | 401 | 2 | 9.9 | 16.2 |
| GET | /api/documents/{id}/download | 403 | 2 | 5.7 | 6.2 |
| POST | /api/documents/generate | 400 | 2 | 6.7 | 8.9 |
| POST | /api/documents/generate | 201 | 2 | 158.5 | 0.0 |
| GET | /api/documents/{id}/download | 200 | 1 | 37.8 | 0.0 |
    document_generation_attempts_seconds_count{application="document-generation-api",outcome="available"} 2
    document_generation_attempts_seconds_sum{application="document-generation-api",outcome="available"} 0.996056345
    document_generation_attempts_seconds_count{application="document-generation-api",outcome="failed"} 0
    document_generation_attempts_seconds_sum{application="document-generation-api",outcome="failed"} 0.0
    document_generation_attempts_seconds_count{application="document-generation-api",outcome="retry"} 0
    document_generation_attempts_seconds_sum{application="document-generation-api",outcome="retry"} 0.0
    document_generation_attempts_seconds_count{application="document-generation-api",outcome="skipped"} 0
    document_generation_attempts_seconds_sum{application="document-generation-api",outcome="skipped"} 0.0
    document_generation_attempts_seconds_max{application="document-generation-api",outcome="available"} 0.0
    document_generation_attempts_seconds_max{application="document-generation-api",outcome="failed"} 0.0
    document_generation_attempts_seconds_max{application="document-generation-api",outcome="retry"} 0.0
    document_generation_attempts_seconds_max{application="document-generation-api",outcome="skipped"} 0.0
    document_generation_in_flight{application="document-generation-api"} 0.0
    document_generation_paused{application="document-generation-api"} 0.0
    document_generation_time_to_available_seconds_count{application="document-generation-api"} 2
    document_generation_time_to_available_seconds_sum{application="document-generation-api"} 1.06798296
    document_generation_time_to_available_seconds_max{application="document-generation-api"} 0.0

