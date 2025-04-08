# Airflow Setup for AIS Data Pipeline

This directory contains the Airflow configuration and DAGs for the AIS data engineering pipeline.

## Setup

### Prerequisites

- Docker and Docker Compose
- GCP service account credentials with the following permissions:
  - Storage Admin (for GCS)
  - BigQuery Admin (for BigQuery datasets and jobs)

### Configuration

1. **Service Account Setup**

   Place your GCP service account JSON key file in the airflow directory:
   ```
   airflow/gcp-service-account.json
   ```

2. **Environment Variables**

   Create a `.env` file in the airflow directory with the following variables:
   ```
   AIRFLOW_UID=50000
   GCP_PROJECT_ID=your-gcp-project-id
   GCS_BUCKET_NAME=ais-data-lake
   BQ_STAGING_DATASET=ais_staging
   ```

   Adjust the values to match your GCP project configuration.

3. **Mount dbt Directory (Optional)**

   If you want to trigger dbt transformations from Airflow, add the following volume mapping to the `x-airflow-common` section in `docker-compose.yml`:
   ```yaml
   - ../dbt:/opt/dbt
   ```

## Running Airflow

1. **Start Airflow**

   ```bash
   cd airflow
   docker-compose up -d
   ```

   The Airflow UI will be available at `http://localhost:8080`
   - Default username: `airflow`
   - Default password: `airflow`

2. **Stop Airflow**

   ```bash
   docker-compose down
   ```

3. **Clean Up Completely**

   ```bash
   docker-compose down -v
   ```

## DAG Configuration

The main DAG for AIS data processing is `ais_ingestion_dag.py`, which performs the following tasks:

1. Generates download URLs for AIS data ZIP files
2. Downloads the ZIP files containing AIS data
3. Extracts CSV files from the ZIP archives
4. Uploads the CSV files to Google Cloud Storage (GCS)
5. Loads the data from GCS to BigQuery staging tables
6. Triggers dbt transformations (requires dbt setup)

## Environment Customization

### Airflow Connections

Before running the DAG, you need to set up a GCP connection in Airflow:

1. Navigate to Admin > Connections in the Airflow UI
2. Add a new connection with the following properties:
   - Connection Id: `google_cloud_default`
   - Connection Type: `Google Cloud`
   - Project Id: Your GCP project ID
   - Keyfile Path: `/opt/airflow/gcp-service-account.json`

### Additional Python Dependencies

If you need additional Python packages in your Airflow environment, adjust the `_PIP_ADDITIONAL_REQUIREMENTS` environment variable in the `docker-compose.yml` file.

## Troubleshooting

- **Permission Issues**: Ensure your service account has the appropriate permissions for GCS and BigQuery operations.
- **Connection Errors**: Verify that your GCP connection is properly configured in Airflow.
- **Missing Data**: Check that the URL for the AIS data source is correct and accessible.
- **Data Format Issues**: Verify that the schema definition in the DAG matches the structure of your AIS CSV files.
