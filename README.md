# AIS Data Engineering Project

## Overview

This project implements a complete data engineering pipeline for AIS (Automatic Identification System) ship tracking data. It includes data extraction, loading, transformation, and visualization components, all orchestrated through Kestra workflows.

![AIS Data Pipeline](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*_wX7JLOQmrpjQ5cdZ8TaMQ.png)

## Architecture

The project follows a modern data engineering architecture:

- **Data Source**: Monthly AIS CSV files in ZIP archives from web.ais.dk
- **Data Lake**: Google Cloud Storage for storing raw CSV files
- **Data Warehouse**: BigQuery for structured data storage and analysis
- **Orchestration**: Kestra for workflow management and scheduling
- **Transformation**: dbt for data modeling and transformation
- **Visualization**: Both Metabase (self-hosted) and Looker Studio (cloud) for dashboards
- **Infrastructure as Code**: Terraform for GCP resource provisioning

## Directory Structure

```
data_engineering_zoomcamp_project/
├── terraform/                 # Infrastructure as Code
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Variable definitions
│   ├── outputs.tf             # Output definitions
│   └── terraform.tfvars       # Terraform variable values
├── kestra/                    # Kestra workflow orchestration
│   ├── docker-compose.yml     # Kestra local setup
│   ├── .env                   # Environment variables
│   └── flows/                 # Kestra flow definitions
│       ├── ais_data_extraction_and_load.yaml  # ETL flow
│       └── ais_data_transformation.yaml       # dbt workflow
├── dbt/                       # Data transformation models
│   ├── models/                # dbt models
│   │   ├── staging/          # Initial data cleaning
│   │   ├── intermediate/     # Business logic transformations
│   │   └── marts/            # Final presentation layer
│   └── ais_data_project/     # dbt project configuration
├── metabase/                  # Self-hosted Metabase
│   ├── docker-compose.yml     # Metabase setup
│   ├── setup_metabase.sh      # Installation script
│   └── queries/               # Example SQL queries
└── Makefile                   # Automation for common tasks
```

## Prerequisites

- Google Cloud Platform account with a project set up
- GCP Service Account with appropriate permissions
- Docker and Docker Compose installed
- Terraform installed (>= v1.0.0)
- Git
- Make

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/data_engineering_zoomcamp_project.git
cd data_engineering_zoomcamp_project
```

### 2. Configure GCP Credentials

1. Create a service account in GCP with the following roles:
   - BigQuery Admin
   - Storage Admin
   - Storage Object Admin

2. Download the service account key file and save it as `de-zoomcamp-project-XXXXX.json` in your project directory.

3. Create a `.env` file in the kestra directory:

```bash
cd kestra
cp .env.example .env
```

4. Edit the `.env` file to include your GCP configuration:

```
GCP_PROJECT_ID=your-project-id
GCP_DATASET=ais_data
GCP_BUCKET_NAME=your-ais-data-bucket
GCP_LOCATION=us-central1
GCP_CREDS="{\"type\":\"service_account\",\"project_id\":\"your-project-id\",\"private_key_id\":\"...\",\"private_key\":\"...\",\"client_email\":\"...\",\"client_id\":\"...\",\"auth_uri\":\"https://accounts.google.com/o/oauth2/auth\",\"token_uri\":\"https://oauth2.googleapis.com/token\",\"auth_provider_x509_cert_url\":\"https://www.googleapis.com/oauth2/v1/certs\",\"client_x509_cert_url\":\"...\",\"universe_domain\":\"googleapis.com\"}"
```

Note: For the `GCP_CREDS` variable, you'll need to format your service account JSON as a one-line string.

### 3. Provision Infrastructure with Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your GCP project details:

```
project_id     = "your-gcp-project-id"
region         = "us-central1"
zone           = "us-central1-a"
bucket_name    = "your-ais-data-bucket"
dataset_id     = "ais_data"
dataset_location = "US"
```

Initialize and apply Terraform:

```bash
make tf-init
make tf-plan
make tf-apply
```

### 4. Start Kestra

```bash
make kestra-up
```

This will start Kestra locally at http://localhost:8080

### 5. Import Kestra Flows

```bash
make import-flows
```

This will upload the extraction/loading and transformation flows to Kestra.

### 6. Start Metabase (Optional)

```bash
make metabase-up
```

Access Metabase at http://localhost:3000 and follow the setup wizard.

## Running the Pipeline

### Manual Trigger

1. Open Kestra UI: http://localhost:8080
2. Navigate to the "ais" namespace
3. Select "ais_data_extraction_and_load" flow
4. Click "Execute" and provide a date in the trigger parameters (YYYY-MM-DD format)
5. After extraction completes, run the "ais_data_transformation" flow

### Scheduled Runs

The extraction flow is configured to run daily at 9 AM. You can modify the schedule in the flow YAML file.

## Dashboard Setup

### Metabase Dashboard

1. Start Metabase using: `make metabase-up`
2. Access Metabase at http://localhost:3000
3. Complete the initial setup
4. Add BigQuery as a data source:
   - Database type: BigQuery
   - Upload your service account JSON file
   - Select the datasets to sync
5. Create dashboards following the example queries in `metabase/queries/`

For detailed instructions, see: `metabase/README.md`

### Looker Studio Dashboard

1. Navigate to [Looker Studio](https://lookerstudio.google.com/)
2. Create a new report
3. Connect to BigQuery using the custom queries:
   - For daily navigational status: Use the query from `metabase/queries/daily_navigational_status.sql`
   - For monthly trends: Use the query from `metabase/queries/monthly_navigational_status.sql`
4. Create visualizations:
   - Pie chart for navigational status distribution
   - Time series for monthly status trends

For detailed instructions, see: `dashboard_implementation_guide.md`

## Makefile Commands

- `make help`: Display available commands
- `make tf-init`: Initialize Terraform
- `make tf-plan`: Create Terraform execution plan
- `make tf-apply`: Apply Terraform changes
- `make kestra-up`: Start Kestra
- `make kestra-down`: Stop Kestra
- `make import-flows`: Import Kestra flows
- `make metabase-up`: Start Metabase
- `make metabase-down`: Stop Metabase
- `make clean`: Clean up temporary files
- `make all`: Set up the complete environment

## Data Transformation

The dbt models create a three-tier transformation layer:

1. **Staging layer**: Initial data cleaning and type conversion
   - Key model: `staging_ais_data.sql`

2. **Intermediate layer**: Business logic, deduplication, and data quality
   - Key model: `int_ais_data.sql`

3. **Mart layer**: Analytics-ready views of the data
   - Daily navigational status: For daily status distribution
   - Monthly navigational status: For time-series analysis

dbt models are automatically run through the Kestra transformation flow.

## Project Components

### ETL Process (Kestra)

The ETL process consists of these key steps:
1. Download AIS data ZIP files from source
2. Extract CSV files from the ZIP archives
3. Upload the CSV files to Google Cloud Storage
4. Create and load data into BigQuery tables with appropriate partitioning
5. Merge new data into the main AIS data table

### Transformation (dbt)

dbt models transform the raw AIS data into analytics-ready formats:
1. Clean and standardize field formats
2. Remove duplicate records
3. Add data quality flags
4. Aggregate data for dashboards:
   - Daily distribution of navigational statuses
   - Monthly trends of navigational statuses over time

### Visualization

The project supports two visualization options:

**Metabase** (Self-hosted):
- Pie chart for daily navigational status distribution
- Time series for monthly navigational status trends
- Interactive filtering by date periods

**Looker Studio** (Cloud):
- Similar visualizations using Google's cloud-based solution
- Direct integration with BigQuery

## Troubleshooting

### Kestra Issues

- Check Kestra logs: `docker logs kestra_kestra_1`
- Verify environment variables in `.env` file
- Ensure GCP credentials are correctly formatted

### BigQuery Issues

- Verify your service account has appropriate permissions
- Check the GCP project and dataset names in your configuration
- Validate SQL syntax in the flow files

### dbt Issues

- Check dbt logs in Kestra UI
- Validate the dbt project structure and dependencies
- Ensure service-account.json is correctly configured

## References

- [Kestra Documentation](https://kestra.io/docs/)
- [dbt Documentation](https://docs.getdbt.com/)
- [Metabase Documentation](https://www.metabase.com/docs/latest/)
- [Looker Studio Documentation](https://support.google.com/looker-studio/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [AIS Data Source](http://web.ais.dk/aisdata/)
