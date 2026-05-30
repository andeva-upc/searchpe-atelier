# Searchpe - Taxpayer Lookup Service (SUNAT)

[![Quarkus](https://img.shields.io/badge/Framework-Quarkus-red.svg?logo=quarkus)](https://quarkus.io/)
[![Java](https://img.shields.io/badge/Language-Java_17-orange.svg?logo=openjdk)](https://openjdk.org/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL_13+-blue.svg?logo=postgresql)](https://www.postgresql.org/)
[![Flyway](https://img.shields.io/badge/Migrations-Flyway-red.svg?logo=flyway)](https://flywaydb.org/)
[![Docker](https://img.shields.io/badge/Container-Docker-blue.svg?logo=docker)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-Apache_2.0-green.svg)](LICENSE)

**Searchpe** is a high-performance, enterprise-grade REST API service built on **Quarkus**, designed to efficiently store, index, and query the Peruvian taxpayers database (RUC) provided by **SUNAT**.

This solution has been customized, optimized, and packaged by the startup **Andeva** to guarantee sub-second response times, high availability, and easy integration with ERP systems, payment gateways, and frontend applications.

---

## Key Features

* **High-Performance Queries:** Instant retrieval of the fiscal information sheet of taxpayers using their RUC number with optimized indexing.
* **Advanced and Paginated Search:** Flexible filtering by Business Name (Razón Social) or RUC, with native support for pagination (`limit`, `offset`) and sorting.
* **Database Automation with Flyway:** Initialization and versioning of the database schema fully automated through secure SQL migrations.
* **Taxpayer Directory Schedulers:** Schedulers (cron jobs) configured to automatically download, process, and import the SUNAT padrón reducido.
* **Flexible and Robust Security:** Support for open mode (development) and protection via HTTP Basic Authentication (production) validated against the database.
* **CORS Enabled by Default:** Configured with open policies (`Origins: *`) to allow direct consumption from frontend applications (React, Angular, Vue, Next.js, etc.) without browser blocks.
* **Container Ready:** Optimized Dockerfile to quickly package and deploy the application in the cloud (Render, AWS, GCP, DigitalOcean).

---

## Data Architecture and Connection

The application is designed to connect to a high-performance remote relational database engine. In deployed testing and production environments, it connects to a managed instance in the cloud (**Aiven Cloud**).

> [!IMPORTANT]
> **Deployed API Database Connection URL:**
> `postgresql://134.209.151.255:13928/defaultdb?sslmode=require`
>
> For the internal JDBC driver configuration in the application (inside `config/application.properties`), the following format is used:
> `jdbc:postgresql://134.209.151.255:13928/defaultdb?sslmode=require`

*(Note: For security reasons, administrative access credentials must be managed via environment variables or through protected local configuration).*

---

## Project Structure

The project is distributed as a pre-compiled and standalone package, ready to run without requiring any compilation steps:

```text
searchpe-atelier/
├── app/                        # Main application JAR file (searchpe-4.1.1.jar)
├── bin/                        # Startup scripts for different operating systems
│   ├── standalone.bat          # Startup script for Windows environments
│   └── standalone.sh           # Startup script for Linux / macOS environments
├── config/                     # Global configuration properties
│   └── application.properties  # Ports, database, and scheduled tasks settings
├── docs/                       # Project documentation files
│   └── API_DOCUMENTATION.md    # Complete technical REST API documentation
├── lib/                        # Shared libraries and dependencies used by the framework
├── quarkus/                    # Quarkus runtime files and build metadata
├── Dockerfile                  # Recipe to build the application container image
├── LICENSE                     # Software License (Apache License 2.0)
└── README.md                   # This general project guide
```

---

## Configuration (application.properties)

Configuration parameters are defined in `config/application.properties`. The key variables and properties are detailed below:

| Property | Description | Default Value |
| :--- | :--- | :--- |
| `quarkus.http.port` | HTTP listening port of the REST server. | `8180` |
| `quarkus.datasource.jdbc.url` | JDBC URL for connection to the PostgreSQL database. | `jdbc:postgresql://134.209.151.255:13928/defaultdb?sslmode=require` |
| `quarkus.datasource.username` | Connection username for the PostgreSQL database. | `avnadmin` |
| `searchpe.allow.advancedSearch` | Enable advanced searches (text/name). | `true` |
| `searchpe.sunat.padronReducidoUrl` | Direct download URL for the SUNAT Padrón. | `http://www2.sunat.gob.pe/padron_reducido_ruc.zip` |
| `searchpe.scheduled.cron` | Schedulers frequency for automatic synchronization. | `0 0 0 * * ?` (Daily at midnight) |

---

## Running the Application

### Option 1: Standalone Local Execution (Recommended for Development)

Ensure you have a Java Runtime Environment installed (**JRE 17 or higher**).

1. Open a terminal in the root directory of the project.
2. Run the script corresponding to your operating system:

   * **On Linux / macOS:**
     ```bash
     chmod +x bin/standalone.sh
     ./bin/standalone.sh
     ```
   * **On Windows:**
     ```cmd
     .\bin\standalone.bat
     ```

3. The Quarkus server will start on the configured port:  
   REST Server: `http://localhost:8180`  
   Web Graphical Console: `http://localhost:8180/`

---

### Option 2: Running via Docker (Ideal for Production / Cloud)

The project includes an optimized `Dockerfile` to package the standalone solution into an ultra-lightweight image.

1. **Build the Docker image:**
   ```bash
   docker build -t searchpe-api:latest .
   ```

2. **Run the container:**
   ```bash
   docker run -d \
     -p 8180:8180 \
     --name searchpe-service \
     -e PORT=8180 \
     searchpe-api:latest
   ```

---

## REST API Documentation

Endpoints are available under the `/api` prefix. A quick reference is provided below:

* **Query by RUC number:**  
  `GET /api/contribuyentes/{ruc}`  
  *Example:* `GET http://localhost:8180/api/contribuyentes/20100078941`

* **Advanced Search and Pagination:**  
  `GET /api/contribuyentes?filterText={query}&limit={limit}`  
  *Example:* `GET http://localhost:8180/api/contribuyentes?filterText=PERU&limit=5`

* **Taxpayer Directory Versions / Status:**  
  `GET /api/versions`  
  *Example:* `GET http://localhost:8180/api/versions`

> [!TIP]
> For complete details on the API response structure, HTTP error codes, code integration snippets for **JavaScript (Fetch)** and **Java (HttpClient)**, and Postman testing guides, refer to the dedicated documentation:
>
> **[API Technical Documentation (API_DOCUMENTATION.md)](docs/API_DOCUMENTATION.md)**

---

## License

This project is licensed under the **Apache 2.0 License**. For more details, refer to the [LICENSE](LICENSE) file.

---
Developed and maintained with heart by **Andeva**. For support or inquiries, contact us.
