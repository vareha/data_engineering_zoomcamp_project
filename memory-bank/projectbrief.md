# Project Brief: Data Engineering Zoomcamp Project

## Overview
This project implements a batch data engineering pipeline focused on processing AIS (Automatic Identification System) ship tracking data. The pipeline ingests monthly AIS CSV files from ZIP archives, stores them in a data lake, transforms them in a data warehouse, and visualizes the results through a dashboard.

## Core Requirements

### Data Pipeline
- Process monthly AIS CSV files (e.g., aisdk-2006-03.zip)
- Implement complete ETL flow: extract, transform, load
- Orchestrate pipeline steps with Airflow
- Transform data using dbt
- Partition data by timestamp in BigQuery

### Cloud Infrastructure
- Use Google Cloud Platform (GCP) services
- Implement Infrastructure as Code (IaC) with Terraform
- Ensure reproducibility with Makefile

### Components
1. **Data Source**: Monthly AIS CSV files in ZIP archives
2. **Data Lake**: Google Cloud Storage (GCS) bucket
3. **Data Warehouse**: BigQuery with staging and curated tables
4. **Orchestration**: Airflow DAG
5. **Transformations**: dbt for cleaning and shaping data
6. **Dashboard**: Looker Studio with categorical and temporal distributions
7. **Infrastructure**: Terraform for GCP resource provisioning

### Deliverables
- Complete GitHub repository with code
- Terraform configurations for GCP resources
- Airflow DAG for orchestration
- dbt models and tests
- Makefile for setup and deployment
- Looker Studio dashboard with at least two tiles
- Comprehensive documentation

## Project Structure
```
your-project/
├── README.md
├── Makefile
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
├── airflow/
│   ├── dags/
│   │   └── ais_ingestion_dag.py
│   └── docker-compose.yml   # If running Airflow locally
├── dbt/
│   ├── dbt_project.yml
│   ├── packages.yml
│   ├── models/
│   │   ├── staging/
│   │   │   └── stg_ais_raw.sql
│   │   └── curated/
│   │       └── ais_curated.sql
│   └── tests/
│       └── ...
├── .github/
│   └── workflows/
│       ├── terraform.yml
│       └── dbt.yml
└── ...
```

## Success Criteria
- End-to-end functional data pipeline
- Queryable transformed data in BigQuery
- Interactive dashboard in Looker Studio
- Reproducible infrastructure and setup process
- Clean code with appropriate documentation

This brief serves as the foundation for our data engineering project, defining the scope, components, and architecture required for successful implementation.
