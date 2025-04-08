# Active Context

## Current Work Focus
- **Phase**: dbt Implementation and Dashboard Development (Days 5-9)
- **Primary Goal**: Implement dbt transformations and create BigQuery-based dashboards
- **Current Priorities**:
  - Create dbt models for dashboard data aggregation
  - Develop Looker Studio dashboards for navigational status visualization
  - End-to-end data flow testing with Kestra and dbt
  - Implementation of daily and monthly navigational status visualizations

## Recent Changes
- Created the repository structure based on PRD requirements
- Implemented Terraform configurations for GCP resources:
  - Google Cloud Storage bucket for raw AIS data
  - BigQuery datasets for staging and curated data
  - API enablement and permissions setup
- Developed Makefile for common operations
- Created detailed README with setup instructions and architecture overview
- Prepared example Terraform variables file
- Implemented Kestra workflow for data orchestration:
  - Configured detailed Kestra YAML flow definition
  - Set up tasks for downloading, extracting, uploading to GCS, and loading to BigQuery
  - Implemented detailed schema for BigQuery data loading
  - Configured proper BigQuery table creation with partitioning
  - Set up monthly trigger schedule
  - Successfully implemented end-to-end data loading to BigQuery
- Established initial dbt models:
  - Created staging model for raw data cleaning
  - Implemented curated model with business logic and transformations
  - Configured partitioning and clustering for performance optimization

## Next Steps

### Implementation Plan
Following the revised timeline:

✅ **1. Infrastructure Setup (Days 1-2)**
   - ✅ Create repository structure
   - ✅ Set up Terraform for GCS and BigQuery
   - ✅ Create Makefile for common operations
   - ✅ Provision GCP resources
   - ✅ Verify infrastructure is ready for data ingestion

✅ **2. Workflow Orchestration Development (Days 3-4)**
   - ✅ Implement Kestra workflow for AIS data ingestion
   - ✅ Configure tasks for:
     - ✅ Downloading AIS ZIP files
     - ✅ Extracting CSV data
     - ✅ Uploading to GCS
     - ✅ Loading to BigQuery
   - ✅ Test workflow execution and data loading

**3. dbt Implementation (Days 5-6)**
   - ✅ Configure initial staging and curated models
   - ⬜ Create mart models for dashboard aggregations:
     - ⬜ Daily navigational status distribution
     - ⬜ Monthly navigational status distribution
   - ⬜ Implement partitioning and clustering
   - ⬜ Create basic data quality tests
   - ⬜ Verify transformations work with loaded data

**4. Integration & Testing (Days 7-8)**
   - ⬜ Ensure Kestra → BigQuery → dbt works end-to-end
   - ⬜ Test with actual AIS data
   - ⬜ Optimize query performance for dashboard use
   - ⬜ Validate data quality in curated tables

**5. Dashboard Development (Day 9)**
   - ⬜ Create Looker Studio dashboards:
     - ⬜ Pie chart for navigational status by day
     - ⬜ Time series/distribution chart for monthly navigational status
   - ⬜ Implement interactive filtering
   - ⬜ Format and publish dashboard

**6. Documentation & Finalization (Day 10)**
   - ⬜ Complete README with detailed setup instructions
   - ⬜ Polish Makefile for usability
   - ⬜ Perform final checks and validation
   - ⬜ Package everything for submission

### Immediate Tasks
1. **dbt Model Implementation**
   - Create mart models for dashboard aggregations
   - Test transformations with loaded data
   - Validate query performance

2. **Dashboard Development Planning**
   - Design layout for the two required visualizations
   - Determine appropriate chart types and filters
   - Plan BigQuery to Looker Studio connection

## Active Decisions and Considerations

### Architecture Decisions
- **Kestra for Workflow Orchestration**: Implemented Kestra for data ingestion and processing
  - Provides declarative YAML-based workflow definition
  - Offers strong integration with GCP services
  - Simpler to configure and maintain than Airflow

- **Data Partitioning Strategy**: Implemented partitioning by event timestamp
  - In BigQuery loading step using partition field specification
  - Reinforced in dbt models for query optimization

- **Kestra Flow Design**: Implemented task-based flow structure
  - Each step in the pipeline is a separate task for clear separation of concerns
  - Defined proper dependencies between tasks
  - Implemented error handling and output management

### Technical Considerations
- **AIS Data Schema**: Defined comprehensive schema in Kestra BigQuery loading step
  - Complete field list with descriptions
  - Data type validations during loading
  - Unique row ID generation for deduplication

- **dbt Model Structure**: Maintained three-layer approach
  - Staging models for initial data cleaning and type conversion
  - Curated models with business logic, partitioning, and enrichment
  - Mart models (to be implemented) for specific dashboard use cases

- **Dashboard Requirements**:
  - Daily visualization: Pie chart of navigational status distribution
  - Monthly visualization: Trend/distribution of navigational statuses over time
  - Interactive filtering for time period selection

### Open Questions
- Performance considerations for large-scale dashboard queries
- Optimal aggregation level for monthly navigational status visualization
- Best approach for interactive dashboard filtering

This active context document captures the current state of the project, outlining immediate tasks, decisions in progress, and considerations that will influence the dbt implementation and dashboard development. It will be updated regularly as the project evolves.
