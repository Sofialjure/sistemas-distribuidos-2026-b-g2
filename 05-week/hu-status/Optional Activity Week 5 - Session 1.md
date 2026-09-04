# Optional Activity — Week 05 · Session 1

## Containerization: Dockerfiles, .dockerignore and Docker Compose

---

## Official Activity

Conteneriza tus servicios: un Dockerfile de varias etapas para cada uno, un archivo `.dockerignore` y un archivo `docker-compose.yml` que inicie todos los servicios y la base de datos en una misma red, con la configuración mediante variables de entorno y los datos en un volumen. Esta es la base de ejecución para la versión MVP 1 (Sesión 2).

---

## Project Context

For TeleMed IA, containerization was applied as part of the preparation of MVP 1. The project contains a backend, a frontend and a PostgreSQL database that need to work together as part of the MVP execution environment.

The containerization configuration was organized using Dockerfiles for the application services and Docker Compose for coordinating the complete environment.

---

## Containerization Structure

The TeleMed IA MVP uses the following containerization components:

| Component | Purpose |
|---|---|
| Backend Dockerfile | Builds and runs the Spring Boot backend |
| Frontend Dockerfile | Builds and runs the frontend |
| `.dockerignore` | Prevents unnecessary files from being included in Docker build contexts |
| `docker-compose.yml` | Coordinates the backend, frontend and PostgreSQL services |
| PostgreSQL volume | Provides persistent database storage |

---

## Backend Multi-Stage Dockerfile

The backend Dockerfile uses a multi-stage build.

```dockerfile
FROM maven:3.9.9-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .

RUN mvn -q -DskipTests dependency:go-offline

COPY src ./src

RUN mvn -q -DskipTests package

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=build /app/target/telemed-backend-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]
```

The first stage uses Maven with Java 17 to build the Spring Boot application. The second stage uses a Java 17 JRE image to run the generated application.

This separates the build environment from the runtime environment and avoids requiring the complete Maven build environment in the final runtime image.

**Evidence:**

- Backend Dockerfile

---

## Docker Ignore Files

The project also includes `.dockerignore` files for the application build contexts.

The purpose of `.dockerignore` is to prevent unnecessary files from being sent to the Docker build context.

This helps avoid including files that are not required to build or execute the application.

**Evidence:**

**Evidence:**

- [Backend `.dockerignore`](https://github.com/JulianaFerro1428/telemed-ai/blob/main/telemedai-backend/.dockerignore)

- [Frontend `.dockerignore`](https://github.com/JulianaFerro1428/telemed-ai/blob/main/telemedai-frontend/.dockerignore)

---

## Docker Compose Configuration

The project uses `docker-compose.yml` to coordinate the PostgreSQL database, backend and frontend.

The main services are:

```yaml
services:

  postgres:
    image: postgres:16-alpine
    container_name: telemed-postgres
    restart: unless-stopped

  backend:
    build:
      context: ./telemedai-backend
      dockerfile: Dockerfile
    container_name: telemed-backend

  frontend:
    build:
      context: ./telemedai-frontend
      dockerfile: Dockerfile
    container_name: telemed-frontend
```

**Evidence:**

- [Docker Compose](https://github.com/JulianaFerro1428/telemed-ai/blob/main/docker-compose.yml)

---

## Database and Persistent Volume

PostgreSQL is defined as a service in Docker Compose.

The database uses a named volume:

```yaml
volumes:
  - telemed_pgdata:/var/lib/postgresql/data
```

The volume is declared at the bottom of the Compose file:

```yaml
volumes:
  telemed_pgdata:
```

This provides persistent storage for PostgreSQL data instead of keeping the database data only inside the disposable container.

---

## Environment Variables

The Compose configuration uses environment variables for database and application configuration:

```yaml
environment:
  POSTGRES_DB: ${POSTGRES_DB:-telemed}
  POSTGRES_USER: ${POSTGRES_USER:-telemed}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-telemed}
```

The backend also receives configuration through environment variables:

```yaml
environment:
  SPRING_PROFILES_ACTIVE: prod
  DB_URL: jdbc:postgresql://postgres:5432/${POSTGRES_DB:-telemed}
  DB_USERNAME: ${POSTGRES_USER:-telemed}
  DB_PASSWORD: ${POSTGRES_PASSWORD:-telemed}
  JWT_SECRET: ${JWT_SECRET}
  CORS_ORIGINS: ${CORS_ORIGINS:-http://localhost:4200}
```

This allows configuration to be provided externally instead of hard-coding environment-specific values inside the application image.

---

## Service Communication and Dependencies

The backend depends on PostgreSQL being healthy:

```yaml
depends_on:
  postgres:
    condition: service_healthy
```

The PostgreSQL service includes a healthcheck:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-telemed} -d ${POSTGRES_DB:-telemed}"]
  interval: 10s
  timeout: 5s
  retries: 5
```

The backend connects to PostgreSQL using the Compose service name:

```text
DB_URL: jdbc:postgresql://postgres:5432/${POSTGRES_DB:-telemed}
```

This allows the containers to communicate through the Docker Compose environment without requiring hard-coded IP addresses.

---

## Complete MVP Execution Environment

The Docker Compose configuration brings together the main components required for the MVP:

```text
TeleMed IA MVP
│
├── PostgreSQL
│   └── Persistent volume: telemed_pgdata
│
├── Backend
│   └── Spring Boot / Java 17
│
└── Frontend
    └── Angular / Ionic
```

The configuration provides a common execution environment where the frontend, backend and database can be started together.

---

## Relationship with MVP 1

Containerization provides the execution base for MVP 1 by allowing the main application components and database to be coordinated through Docker Compose.

The configuration includes:

- Backend containerization.
- Frontend containerization.
- PostgreSQL containerization.
- Environment-based configuration.
- Database healthcheck.
- Service dependencies.
- Persistent database storage.
- Docker build configuration.

These elements support a reproducible execution environment for the MVP.

---

## Activity Result

The containerization activity was applied to the TeleMed IA MVP using Dockerfiles, `.dockerignore` files and Docker Compose.

The backend uses a multi-stage Dockerfile, while Docker Compose coordinates the frontend, backend and PostgreSQL services. Environment variables are used for configuration, and PostgreSQL uses a persistent volume for its data.

This establishes the Docker-based execution environment required as the basis for the MVP 1 release.