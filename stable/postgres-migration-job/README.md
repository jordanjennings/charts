# Postgres Database Migration Job

## Chart Details

This Chart is a partial for an application Chart to schedule a job to migrate the database to the current version with Flyway. https://flywaydb.org/
It uses vault-init-container to obtain credentials from HashiCorp Vault to perform the database migrations.

## Using the Chart

Add this Chart to your `requirements.yaml`:

```yaml
dependencies:
  - name: postgres-migration-job
    version: 0.0.1
    repository: "https://bossanova.jfrog.io/bossanova/charts"
```

As part of the values supplied from your chart, you must include the following

Parameter                             | Description
-------------------------------       | -----------
postgresMigrationEnv.FLYWAY_URL       | The JDBC url to use to connect to the database
postgresMigrationEnv.FLYWAY_SCHEMAS   | Comma-separated case-sensitive list of schemas managed by Flyway.
postgresMigrationEnv.FLYWAY_LOCATIONS | Comma-separated list of locations to scan recursively for migrations. The location type is determined by its prefix.
postgresMigrationEnv.FLYWAY_JAR_DIRS  | Comma-separated list of directories containing JDBC drivers and Java-based migrations

## Example Usage

1. Create or add to your chart templates `jobs.yaml` to include the migration job:

```yaml
# Before container starts, run job to migrate postgresql database to current version
{{- include "postgres_migration_job" . }}
```

2. Define these values in your application chart:

```yaml
postgresMigrationEnv:
  FLYWAY_URL: jdbc:postgresql://master.postgresql.service.consul:5432/app_db?sslmode=require
  FLYWAY_SCHEMAS: appschema
  FLYWAY_JAR_DIRS: /srv/app-artifact
  FLYWAY_LOCATIONS: classpath:db/migration[/component]
```

3. Install the implementing Chart. A migration job will be created as part of bring up. The job will only run once.

The job will be called CHARTNAME-pgmj-RELERASETIMEINSECONDS, e.g.
```
templeton-peck-pgmj-1527624879
```
