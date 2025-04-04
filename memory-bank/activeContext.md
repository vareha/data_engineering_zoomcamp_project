# Active Context

## Current Work Focus
- **Phase**: Infrastructure Implementation (Days 1-2)
- **Primary Goal**: Set up infrastructure as code for GCP resources
- **Current Priorities**:
  - Terraform configuration for GCS and BigQuery resources
  - Makefile for automation of common tasks
  - Project structure and documentation

## Recent Changes
- Created the repository structure based on PRD requirements
- Implemented Terraform configurations for GCP resources:
  - Google Cloud Storage bucket for raw AIS data
  - BigQuery datasets for staging and curated data
  - API enablement and permissions setup
- Developed Makefile for common operations
- Created detailed README with setup instructions and architecture overview
- Prepared example Terraform variables file

## Next Steps

### Implementation Plan
Following the timeline from the PRD:

✅ **1. Infrastructure Setup (Days 1-2)**
   - ✅ Create repository structure
   - ✅ Set up Terraform for GCS and BigQuery
   - ✅ Create Makefile for common operations
   - ⬜ Provision GCP resources (pending user credentials)
   - ⬜ Verify infrastructure is ready for data ingestion

**2. Airflow DAG Development (Days 3-4)**
   - Set up local Airflow environment with docker-compose
   - Create initial DAG structure with tasks for:
     - Downloading AIS ZIP files
     - Extracting CSV data
     - Uploading to GCS
     - Loading to BigQuery staging
     - Running dbt transformations
   - Test individual tasks and connections

**3. dbt Implementation (Days 5-6)**
   - Build staging and curated models
   - Implement partitioning and clustering
   - Create basic data quality tests
   - Verify transformations work with test data

**4. Integration & Testing (Days 7-8)**
   - Ensure Airflow → BigQuery → dbt works end-to-end
   - Test with actual AIS data
   - Optimize performance and error handling
   - Validate data quality in curated tables

**5. Dashboard Development (Day 9)**
   - Create Looker Studio charts
   - Implement categorical distribution visualization
   - Implement temporal distribution visualization
   - Format and publish dashboard

**6. Documentation & Finalization (Day 10)**
   - Complete README with detailed setup instructions
   - Polish Makefile for usability
   - Perform final checks and validation
   - Package everything for submission

### Immediate Tasks
1. **Infrastructure Provisioning**
   - Obtain GCP service account credentials
   - Run `make tf-apply` to provision resources
   - Verify resources are created correctly

2. **Prepare for Airflow Development**
   - Set up docker-compose.yml for Airflow
   - Configure environment variables for GCP connectivity
   - Create placeholder for AIS ingestion DAG

## Active Decisions and Considerations

### Architecture Decisions
- **Local vs. Cloud Airflow**: Decided to use local Docker-based Airflow for development
  - Provides more control and lower costs during development
  - Can be migrated to Cloud Composer if needed for production

- **Data Partitioning Strategy**: Confirmed partitioning by event timestamp
  - Optimizes for time-based queries, which will be common in AIS data analysis
  - Will be implemented in dbt models

### Technical Considerations
- **AIS Data Schema**: Planning to define schema in both BigQuery loading step and dbt models
  - Core fields identified: timestamp, mmsi, coordinates, vessel type, navigational status
  - Will handle schema evolution if source data changes

- **BigQuery Loading**: Will use GCSToBigQueryOperator with schema definition
  - Provides control over data types and validation
  - Schema explicitly defined rather than relying on autodetect for production reliability

- **dbt Model Structure**: Planning two-layer approach
  - Staging models for initial data cleaning and type conversion
  - Curated models with business logic, partitioning, and enrichment

### Open Questions
- Exact source location for AIS ZIP files (currently using placeholder URL)
- Volume of data and associated performance considerations
- Specific requirements for Looker Studio visualizations

This active context document captures the current state of the project, outlining immediate tasks, decisions in progress, and considerations that will influence development. It will be updated regularly as the project evolves.
