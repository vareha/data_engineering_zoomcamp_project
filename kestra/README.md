# Kestra Workflow for AIS Data Ingestion

This directory contains Kestra workflow configuration for ingesting AIS (Automatic Identification System) data. The workflow duplicates the functionality of the Airflow implementation while using Kestra's workflow engine.

## Directory Structure

```
kestra/
├── docker-compose.yml       # Docker Compose configuration for Kestra
├── configuration.yml        # Kestra server configuration
├── workflows/               # Kestra workflows directory
│   └── ais_ingestion_flow.yml  # AIS data ingestion workflow
```

## Setup Instructions

### Prerequisites

- Docker and Docker Compose installed
- Google Cloud Platform (GCP) account with:
  - A service account with appropriate permissions for GCS and BigQuery
  - Service account credentials (JSON key file)

### Configuration

1. Place your GCP service account credentials in `kestra/gcp-credentials.json`

2. Create a `.env` file in the `kestra` directory with the following variables:

```
GCP_PROJECT_ID=your-gcp-project-id
GCS_BUCKET_NAME=ais-data-lake
BQ_STAGING_DATASET=ais_staging
```

3. Start Kestra using Docker Compose:

```bash
cd kestra
docker compose up -d
```

4. Access the Kestra UI at `http://localhost:8080`

## AIS Ingestion Workflow

The `ais_ingestion_flow.yml` workflow handles the following tasks:

1. **Generate Date Range** - Creates a list of year-month combinations between the start and end dates
2. **Generate Download URLs** - Constructs URLs for the AIS data ZIP files based on the date range
3. **Download ZIP Files** - Downloads the ZIP files containing AIS data
4. **Extract CSV Files** - Extracts CSV files from the ZIP archives
5. **Upload to GCS** - Uploads the extracted CSV files to Google Cloud Storage
6. **Load to BigQuery** - Loads the data from GCS to BigQuery staging tables
7. **Cleanup** - Removes temporary files after processing

## Running the Workflow

### Via the UI

1. Navigate to the Kestra UI at `http://localhost:8080`
2. Find the `ais_ingestion_flow` in the `ais` namespace
3. Click "Execute" to run the workflow
4. Optionally provide custom start and end dates in the input form

### Via the API

You can also trigger the workflow via the Kestra API:

```bash
curl -X POST http://localhost:8080/api/v1/executions \
  -H "Content-Type: application/json" \
  -d '{
    "namespace": "ais",
    "flowId": "ais_ingestion_flow",
    "inputs": {
      "start_date": "2023-01-01",
      "end_date": "2023-01-31"
    }
  }'
```

## Schedule

The workflow is configured to run monthly on the 1st day of each month at midnight. You can modify the schedule in the `triggers` section of the workflow file.

## Comparison with Airflow

This Kestra implementation provides the same functionality as the Airflow DAG but with some key differences:

1. **Configuration** - Kestra uses YAML for workflow definition instead of Python
2. **Variables** - Kestra handles variables through its templating system
3. **Execution** - Kestra has a built-in web UI that doesn't require separate components
4. **Storage** - Kestra uses PostgreSQL for workflow state storage
5. **Plugins** - Kestra has a plugin system for extensibility, with GCP plugins pre-installed

Both implementations follow the same general flow and accomplish the same tasks.
