# Optional Activity — Week 6 — Session 1
## Docker Compose and Orchestration Basics

### Objective

Validate that the TeleMed IA MVP can be started as a multi-service system using Docker Compose, with shared networking, service dependencies, health checks, environment-based configuration, and persistent database storage.

### Current Docker Compose Topology

The TeleMed IA MVP is composed of three services:

- **frontend** — Angular/Ionic application.
- **backend** — Spring Boot application.
- **postgres** — PostgreSQL 16 database.

The services are defined in a single `docker-compose.yml` file.

### Service Communication

Docker Compose provides a shared network for the services. The backend connects to PostgreSQL using the service name `postgres` instead of `localhost`.

The backend uses:

```
jdbc:postgresql://postgres:5432/${POSTGRES_DB:-telemed}
```

This allows the containers to communicate through the Docker Compose service name.

### Startup Dependencies

The backend depends on PostgreSQL:

```yaml
depends_on:
  postgres:
    condition: service_healthy
```

This prevents the backend from starting its dependency flow until PostgreSQL reports a healthy status.

### Health Check

PostgreSQL includes a health check using `pg_isready`:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-telemed} -d ${POSTGRES_DB:-telemed}"]
  interval: 10s
  timeout: 5s
  retries: 5
```

The health check verifies that PostgreSQL is ready to accept connections.

### Persistent Data

PostgreSQL uses the named volume:

```yaml
volumes:
  - telemed_pgdata:/var/lib/postgresql/data
```

This allows database data to persist across container restarts.

### Environment Configuration

The Compose configuration uses environment variables for database credentials, JWT configuration, and CORS:

- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `JWT_SECRET`
- `CORS_ORIGINS`

Default values are used where appropriate, while sensitive values such as `JWT_SECRET` are expected to come from the environment.

### Validation

The complete system is started with:

```
docker compose up --build
```

The expected services are:

- `telemed-postgres`
- `telemed-backend`
- `telemed-frontend`

The main application ports are:

| Service    | Port |
|------------|------|
| Frontend   | 4200 |
| Backend    | 8080 |
| PostgreSQL | 5432 |

### Result

The MVP currently demonstrates a containerized multi-service environment using Docker Compose, shared service networking, PostgreSQL health checks, startup dependencies, environment variables, and persistent database storage.

### Evidence

The following evidence supports the current Docker Compose implementation:

1. **Docker Compose configuration**
   - The project's `docker-compose.yml` defines the `frontend`, `backend`, and `postgres` services.
   - PostgreSQL includes a health check and persistent volume.
   - The backend uses the PostgreSQL service name for container-to-container communication.

2. **Running containers**
   - Docker execution was validated with the TeleMed IA containers running:
     - `telemed-frontend`
     - `telemed-backend`
     - `telemed-postgres`

3. **Application availability**
   - The frontend is available on port `4200`.
   - The backend is available on port `8080`.
   - PostgreSQL is exposed on port `5432`.

4. **Persistent storage**
   - PostgreSQL uses the named Docker volume `telemed_pgdata`.

### Evidence Files / Screenshots

The evidence for this activity can include:
- Docker containers running. ![Docker running](<../../04-week/hu-status/Optional Activity Week 4 - Session 1 - Docker.png>)
- TeleMed IA frontend running locally. ![TeleMed IA frontend running locally](<Image TeleMed IA frontend running locally.png>)
- Docker Compose configuration showing `depends_on`, health check, environment variables, and volume configuration.

```text
services:

  postgres:
    image: postgres:16-alpine
    container_name: telemed-postgres
    restart: unless-stopped

    environment:
      POSTGRES_DB: ${POSTGRES_DB:-telemed}
      POSTGRES_USER: ${POSTGRES_USER:-telemed}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-telemed}

    ports:
      - "5432:5432"

    volumes:
      - telemed_pgdata:/var/lib/postgresql/data

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-telemed} -d ${POSTGRES_DB:-telemed}"]
      interval: 10s
      timeout: 5s
      retries: 5


  backend:
    build:
      context: ./telemedai-backend
      dockerfile: Dockerfile

    container_name: telemed-backend
    restart: unless-stopped

    depends_on:
      postgres:
        condition: service_healthy

    environment:
      SPRING_PROFILES_ACTIVE: prod
      DB_URL: jdbc:postgresql://postgres:5432/${POSTGRES_DB:-telemed}
      DB_USERNAME: ${POSTGRES_USER:-telemed}
      DB_PASSWORD: ${POSTGRES_PASSWORD:-telemed}
      JWT_SECRET: ${JWT_SECRET}
      CORS_ORIGINS: ${CORS_ORIGINS:-http://localhost:4200}

    ports:
      - "8080:8080"


  frontend:
    build:
      context: ./telemedai-frontend
      dockerfile: Dockerfile

    container_name: telemed-frontend
    restart: unless-stopped

    depends_on:
      - backend

    ports:
      - "4200:4200"


volumes:
  telemed_pgdata:
  ```

### Scope Note

This activity validates the current MVP containerization. Full production orchestration and multi-host deployment are part of the future evolution of the distributed architecture.