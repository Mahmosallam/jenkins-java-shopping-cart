# Shopping Cart (Spring Boot)

A simple shopping cart web application built with Spring Boot 1.5.x, Spring Security, Thymeleaf, and JPA. The app uses an in‑memory H2 database by default and ships with a sample dataset.

## Features
- User registration and login (Spring Security)
- Product listing with pagination
- Add/remove products to/from shopping cart and checkout
- H2 in‑memory database with seed data
- Dockerfile for containerized deployment
- Jenkins pipeline with build, tests, security scans (OWASP DC, Trivy), SonarQube, and Kubernetes deploy

## Tech stack
- Java 8, Maven
- Spring Boot 1.5.3
- Spring MVC, Spring Data JPA, Spring Security
- Thymeleaf
- H2 (default) and MySQL driver included

## Prerequisites
- JDK 8
- Maven 3.6+

Optional (for CI/CD and deployment):
- Docker
- Jenkins with required plugins (OWASP Dependency-Check, HTML Publisher, Slack, SonarQube)
- SonarQube scanner configured as `sonarqube`
- Trivy installed on the Jenkins agent
- Kubernetes cluster access and kubeconfig (see `k8s/config`)

## Getting started (local)
1. Build:
   ```bash
   mvn clean package
   ```
2. Run:
   ```bash
   java -jar target/shopping-cart-0.0.1-SNAPSHOT.jar
   ```
3. App URLs:
   - Application: http://localhost:8070/home
   - Login: http://localhost:8070/login
   - H2 Console: http://localhost:8070/h2-console (JDBC URL `jdbc:h2:mem:shopping_cart_db`, user `sa`, empty password)

Seed users (from `src/main/resources/sql/import-h2.sql`):
- user/password, johndoe/password, namesurname/password (ROLE_USER)

Note: Spring Security also configures an in‑memory ADMIN using properties `spring.admin.username` and `spring.admin.password` (both default to `admin`).

## Configuration
App defaults are under `src/main/resources/application.properties`.
- Server port: `8070`
- H2 datasource: `jdbc:h2:mem:shopping_cart_db`
- H2 console path: `/h2-console`
- JPA auth queries and admin credentials are property‑driven

To switch to MySQL, provide appropriate Spring Boot datasource properties at runtime, and ensure the schema/data exist.

## Run with Docker
1. Build the Jar locally first:
   ```bash
   mvn clean package -DskipTests
   ```
2. Build the image:
   ```bash
   docker build -t java-shop -f Dockerfile .
   ```
3. Run the container:
   ```bash
   docker run --rm -p 8070:8070 java-shop
   ```

## Jenkins pipeline
The provided `Jenkinsfile` contains stages:
- build (mvn package), unit test
- OWASP Dependency-Check (HTML report archived)
- SonarQube Analysis
- Dockerize (build image `java-shop`)
- Trivy scan (JSON + HTML reports archived)
- Login and push to Docker Hub (uses credentials id `docker-hup`)
- Deploy to Kubernetes using `k8s/deploy.yml` and kubeconfig at `k8s/config` (context `sallam`)

Adjust tool names (e.g., `mvn363`, `java8`, `java11`, `sonarqube`) to match your Jenkins global tool configuration.

## Kubernetes deployment
K8s manifests live in `k8s/`:
- `deploy.yml` defines a `Deployment` (2 replicas) and a `Service` (LoadBalancer on port 8070, nodePort 30008). Image defaults to `osos3/java-shop:latest`.
- `permission.yml` includes Role/RoleBinding for a Jenkins deployer user.
- `config` is an example kubeconfig used by the pipeline.

Apply manually if needed:
```bash
kubectl apply -f k8s/deploy.yml --kubeconfig k8s/config --context sallam
```

## Development notes
- Thymeleaf templates are in `src/main/resources/templates`
- Static assets under `src/main/resources/static`
- Initial data under `src/main/resources/sql/import-h2.sql`

## License
This project is provided as-is for educational/demo purposes.