# Optional Activity — Week 6 — Session 2
## Environments, Configuration Strategy and Orchestration

### Objective

Define the environment and configuration strategy for the future evolution of TeleMed IA, while documenting the current MVP situation.

### Environment Strategy

The project defines three target environments:

| Environment | Purpose |
|---|---|
| Development | Fast development and local validation. |
| QA | Integration and testing in an environment similar to production. |
| Production | Stable environment for real users. |

The same application artifact should be promoted between environments. The configuration changes according to the target environment.

### Configuration Strategy

Configuration should remain outside the application code whenever possible.

The application already uses environment variables for important configuration values, including:

- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `JWT_SECRET`
- `CORS_ORIGINS`
- `PORT`

Spring Boot reads these values from the environment.

### Secrets

Sensitive values such as database passwords and JWT secrets must not be committed to the repository.

The project uses a `.env.example` file in the root of the TeleMed IA repository to document the required environment variables without exposing production or personal secrets.

The `.env.example` file is part of the project's configuration documentation and is not stored inside the weekly evidence folder.


### Branch and Environment Strategy

The course proposes the following workflow:

```text
hu-xxx-dev
     ↓
PR develop
     ↓
develop
     ↓
QA
     ↓
main
     ↓
Production
```

This branch-to-environment workflow was not used during the development of the current MVP 1.

The MVP was developed and released without implementing the proposed branch-to-environment workflow.

This workflow will begin to be applied in the next development stage, as the project evolves from the current modular monolith toward independent microservices.

### Orchestration Strategy

The current MVP already implements part of the orchestration strategy through Docker Compose:

- The complete local system can be started using a single `docker compose up --build` command.
- PostgreSQL uses a health check based on `pg_isready`.
- The backend depends on PostgreSQL using `condition: service_healthy`.
- Configuration values are provided through environment variables.
- PostgreSQL data is persisted using a named Docker volume.

The following orchestration capabilities remain planned for the future evolution of the project:

- Deploying the system across multiple hosts.
- Using QA and Production environments with environment-specific configuration.
- Promoting the same application artifacts between environments.
- Applying the branch-to-environment workflow during microservice development.

### MVP 2 / Future Evolution

The team has not started implementing MVP 2 yet. The current activity therefore documents the planned orchestration work rather than claiming implementation.

The next development stage will evolve the current modular monolith toward independent microservices.

### Result

The environment, configuration, branch strategy, and orchestration concepts have been documented as a planning baseline for the next stage of TeleMed IA.

### Evidence

The following evidence supports the configuration strategy documented in this activity:

1. **Environment template**
   - A `.env.example` file was added to the root of the TeleMed IA repository.
   - It documents the environment variables required by the local Docker Compose configuration without exposing real production credentials.

2. **Git protection for local environment variables**
   - The project's `.gitignore` includes `.env`, preventing the local environment file from being committed to Git.

3. **Environment configuration**
   - Docker Compose reads database, JWT, and CORS configuration from environment variables.
   - Spring Boot receives the corresponding configuration through environment variables.

4. **Branch and environment strategy**
   - The proposed `hu-xxx-dev → develop → QA → main` workflow is documented as a future strategy.
   - This workflow was not used during MVP 1 and will be incorporated during the next development stage with the construction of independent microservices.

### Evidence Files / Screenshots

The evidence for this activity can include:
- `.env.example` in the root of the TeleMed IA repository.  ![.env.example](<Image .env.example.png>)
- `.gitignore` showing `.env`.

`.gitignore`
```text
target/
.idea/
*.iml
.env

```
- Docker Compose configuration using environment variables.
![Docker Compose configuration using environment variables](<Image Docker Compose configuration using environment variables.png>)
![Docker Compose configuration using environment variables](<Image 2 Docker Compose configuration using environment variables.png>)
- Environment Configuration Matrix documented for Development, QA, and Production.
![Environment Configuration Matrix documented for Development, QA, and Production](<Image Environment Configuration Matrix documented for Development, QA, and Production.png>)
### Scope Note

No new microservices or branch workflow were implemented as part of this activity.