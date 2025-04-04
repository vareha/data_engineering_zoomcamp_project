# AIS Data Engineering Pipeline

A complete data engineering pipeline for processing AIS (Automatic Identification System) ship tracking data.

## Architecture

This project implements a batch data pipeline using the following components:

```
Data Source (AIS ZIP Files) → GCS → BigQuery → dbt → Looker Studio
         ↑                     ↑       ↑        ↑
         └─────────────────── Airflow ─────────┘
                                ↑
                            Terraform
                                ↑
                             Makefile
```

- **Data Source**: Monthly AIS CSV files in ZIP archives
- **Data Lake**: Google Cloud Storage (GCS)
- **Data Warehouse**: BigQuery
- **Orchestration**: Airflow
- **Transformation**: dbt
- **Visualization**: Looker Studio
- **Infrastructure**: Terraform
- **Automation**: Makefile

## Project Structure

```
ais-pipeline/
├── README.md                 # This file
├── Makefile                  # Automation for common tasks
├── terraform/                # Infrastructure as Code
│   ├── main.tf               # Main Terraform configuration
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output values
│   └── terraform.tfvars      # Variable values (create from example)
├── airflow/                  # Airflow configuration
│   ├── dags/                 # DAG definitions
│   │   └── ais_ingestion_dag.py  # Main pipeline DAG
│   └── docker-compose.yml    # Local Airflow setup
├── dbt/                      # dbt transformations
│   ├── dbt_project.yml       # dbt project configuration
│   ├── profiles.yml          # dbt connection profiles
│   ├── models/               # dbt models
│   │   ├── staging/          # Staging models
│   │   │   └── stg_ais_raw.sql  # Raw data staging
│   │   └── curated/          # Curated models
│   │       └── ais_curated.sql  # Processed data
│   └── tests/                # dbt tests
└── .github/                  # CI/CD configuration
    └── workflows/            # GitHub Actions workflows
```

## Getting Started

### Prerequisites

- Google Cloud Platform account with billing enabled
- Python 3.8+
- Terraform
- Docker and Docker Compose
- Make

### Setup

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/ais-pipeline.git
   cd ais-pipeline
   ```

2. Create `terraform.tfvars` from the example:
   ```
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

3. Edit `terraform.tfvars` to set your GCP project ID and other variables.

4. Set up GCP credentials:
   ```
   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service-account-key.json
   ```

5. Initialize the project:
   ```
   make init
   ```

6. Set up infrastructure:
   ```
   make tf-apply
   ```

7. Start Airflow locally:
   ```
   make airflow-up
   ```

8. Access Airflow UI at http://localhost:8080 and trigger the DAG.

## Development

### Infrastructure

Update Terraform configurations in the `terraform/` directory. Preview changes with:

```
make tf-plan
```

Apply changes with:

```
make tf-apply
```

### Pipeline

Modify the Airflow DAG in `airflow/dags/ais_ingestion_dag.py` to adjust the pipeline workflow.

### Transformations

Edit dbt models in the `dbt/models/` directory. Run transformations with:

```
make dbt-run
```

Run tests with:

```
make dbt-test
```

## Dashboard

Access the Looker Studio dashboard at [dashboard-link] (to be added after creation).

## Implementation Plan

This project follows a structured implementation approach:

1. **Infrastructure Setup (Days 1-2)**
   - Set up Terraform for GCS & BigQuery
   - Provision required resources

2. **Airflow DAG (Days 3-4)**
   - Implement ingestion steps (download, extract, load)
   - Set up local environment

3. **dbt Implementation (Days 5-6)**
   - Build staging & curated models
   - Implement partitioning and tests

4. **Integration & Testing (Days 7-8)**
   - Ensure end-to-end workflow
   - Test with realistic data

5. **Dashboard (Day 9)**
   - Create Looker Studio visualizations
   - Implement required tiles

6. **Documentation (Day 10)**
   - Finalize documentation
   - Polish project structure

## License

[Your License Information]

## Acknowledgments

- [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp)
