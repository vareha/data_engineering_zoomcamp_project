# Active Context

## Current Work Focus
- **Phase**: Dashboard Development and Finalization (Days 8-10)
- **Primary Goal**: Create Looker Studio dashboards and finalize project documentation
- **Current Priorities**:
  - Implement Looker Studio dashboards using the created dbt mart models
  - Test end-to-end data flow from Kestra through dbt to Looker Studio
  - Complete the project documentation
  - Prepare final submission

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
- Implemented complete dbt transformation layer:
  - Created staging model for raw data cleaning
  - Implemented intermediate model with data cleaning, deduplication, and business logic
  - Developed mart models for dashboard visualizations:
    - Daily navigational status distribution model for pie charts
    - Monthly navigational status model for time series analysis
  - Created comprehensive tests and documentation
  - Fixed issue with positive_values test to handle zero count records
  - Configured proper partitioning and clustering for performance
- Switched from Looker Studio to self-hosted Metabase for dashboards:
  - Created comprehensive Metabase implementation guide
  - Set up Docker-based Metabase configuration
  - Developed installation and setup script
  - Created example SQL queries for dashboard components
  - Prepared complete documentation for Metabase setup and usage

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
   - ✅ Create mart models for dashboard aggregations:
     - ✅ Daily navigational status distribution
     - ✅ Monthly navigational status distribution
   - ✅ Implement partitioning and clustering
   - ✅ Create basic data quality tests
   - ✅ Verify transformations work with loaded data

**4. Integration & Testing (Days 7-8)**
   - ✅ Ensure Kestra → BigQuery → dbt works end-to-end
   - ✅ Test with actual AIS data
   - ✅ Optimize query performance for dashboard use
   - ✅ Validate data quality in curated tables

**5. Dashboard Development (Day 9)**
   - ⏳ Create dashboards using self-hosted Metabase:
     - ⏳ Pie chart for navigational status by day
     - ⏳ Time series/distribution chart for monthly navigational status
   - ✅ Develop detailed Metabase implementation guide 
   - ✅ Set up Docker configuration for Metabase
   - ✅ Create example SQL queries for visualizations
   - ⏳ Implement interactive filtering
   - ⏳ Format and publish dashboard

**6. Documentation & Finalization (Day 10)**
   - ⬜ Complete README with detailed setup instructions
   - ⬜ Polish Makefile for usability
   - ⬜ Perform final checks and validation
   - ⬜ Package everything for submission

### Immediate Tasks
1. **Metabase Dashboard Implementation**
   - Set up Metabase using the provided Docker configuration
   - Create dashboards following the implementation guide
   - Implement both daily and monthly navigational status visualizations
   - Set up interactive filtering
   - Optimize performance and appearance

2. **Final Documentation**
   - Complete the README with detailed setup and usage instructions
   - Document the end-to-end pipeline flow
   - Prepare final submission materials

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
  - Daily visualization: Pie chart of navigational status distribution in Metabase
  - Monthly visualization: Trend/distribution of navigational statuses over time
  - Interactive filtering for time period selection
  - Self-hosted solution using Docker for Metabase

### Data Quality Considerations
- Ensured proper data cleaning in the intermediate layer:
  - Handling duplicate unique_row_id values 
  - Standardizing field formats and values
  - Adding flags for valid positions and MMSI values
- Modified data quality tests to handle valid edge cases:
  - Allow zero counts for navigational statuses (valid in real-world data)
  - Allow NULL values in certain metrics
  - Maintained essential not_null tests for key fields

### Open Questions
- Performance considerations for large-scale dashboard queries in Metabase
- Optimal aggregation level for monthly navigational status visualization
- Configuration of BigQuery service account for Metabase connection
- Impact of switching from Looker Studio to Metabase on project requirements

This active context document captures the current state of the project, outlining immediate tasks, decisions in progress, and considerations that will influence the dbt implementation and dashboard development. It will be updated regularly as the project evolves.
