# Environment Configuration Matrix

## TeleMed IA — Week 6

The following matrix documents the planned configuration strategy for the three target environments.

| Variable | Development | QA | Production |
|---|---|---|---|
| `POSTGRES_DB` | `telemed` | QA-specific value | Production-specific value |
| `POSTGRES_USER` | `telemed` | QA-specific user | Production-specific user |
| `POSTGRES_PASSWORD` | Development value | QA secret | Production secret |
| `JWT_SECRET` | Development value | QA secret | Production secret |
| `CORS_ORIGINS` | `http://localhost:4200` | QA frontend URL | Production frontend URL |

## Configuration Rules

- The same application artifact should be promoted between environments.
- Environment-specific values should be injected through configuration.
- Secrets must not be committed to Git.
- `.env.example` should document the required variables without containing real production secrets.
- Variable names should remain consistent across environments.
- Required configuration should be validated at application startup.

## Current MVP

The current MVP already uses environment variables for important configuration through Docker Compose and Spring Boot.

The Development configuration currently uses the local PostgreSQL database `telemed`, the `telemed` database user, and the local frontend origin `http://localhost:4200`.

The QA and Production values have not been implemented yet and are documented as planned configuration for the future evolution of the project.

## Branch and Environment Status

The branch-to-environment workflow proposed by the course was not used during MVP 1.

It will be incorporated in the next development stage, when the team begins constructing the independent microservices.

### Configuration Mapping

The external environment configuration is provided through Docker Compose.

For example:

```text
POSTGRES_DB       → Docker Compose → DB_URL
POSTGRES_USER     → Docker Compose → DB_USERNAME
POSTGRES_PASSWORD → Docker Compose → DB_PASSWORD
JWT_SECRET        → Docker Compose → JWT_SECRET
CORS_ORIGINS      → Docker Compose → CORS_ORIGINS
```

This allows the application configuration to remain independent from environment-specific values.