# Technical Context

## Technologies Used

### Core Technologies
1. **Google Cloud Platform (GCP)**
   - **Google Cloud Storage (GCS)**: Data lake for storing raw CSV files
   - **BigQuery**: Serverless data warehouse for staging and curated data
   - **Looker Studio**: Data visualization and dashboard creation

2. **Orchestration & Workflow**
   - **Kestra**: Workflow orchestration for pipeline execution
   - **Docker**: Containerization for local Kestra deployment

3. **Data Transformation**
   - **dbt (data build tool)**: SQL-based transformation framework
   - **SQL**: Primary language for data transformations in BigQuery and dbt

4. **Infrastructure Management**
   - **Terraform**: Infrastructure as Code (IaC) for GCP resource provisioning
   - **Make**: Build automation tool for streamlining common tasks

5. **Version Control & CI/CD**
   - **Git**: Version control system
   - **GitHub**: Repository hosting and collaboration
   - **GitHub Actions**: CI/CD for automated testing and deployment (optional)

## Development Setup

### Local Environment Requirements
1. **Required Software**
   - Docker and Docker Compose (for local Kestra)
   - Terraform CLI
   - GNU Make
   - Git
   - Java 11+ (for Kestra server)

2. **Cloud Accounts and Access**
   - GCP account with billing enabled
   - Service account with appropriate permissions:
     - Storage Admin (for GCS)
     - BigQuery Admin (for BQ datasets and jobs)

3. **Configuration Files**
   - Terraform variables file (`terraform.tfvars`) with GCP project configuration
   - Kestra environment variables file (`.env`) for configuration
   - dbt profiles for BigQuery connection
   - Service account credentials JSON

### Development Workflow
1. **Environment Setup**
   - Clone repository
   - Run `make init` to initialize local environment
   - Configure GCP credentials and project settings

2. **Infrastructure Provisioning**
   - Run `make tf-plan` to preview infrastructure changes
   - Run `make tf-apply` to create GCP resources

3. **Local Testing**
   - Run Kestra locally with `make kestra-up`
   - Test dbt models with `make dbt-test`
   - Validate complete pipeline with `make pipeline`

4. **Deployment**
   - Push changes to repository
   - CI/CD will validate Terraform configuration and dbt models
   - Manual approval for production deployments

## Technical Constraints

### Data Processing
1. **Volume Considerations**
   - Monthly AIS CSV files can be large (potential GBs of data)
   - BigQuery has quotas for loading and query processing
   - Consider partitioning and clustering for performance

2. **Schema Evolution**
   - AIS data schema must be properly defined for BigQuery loading
   - Changes to source data format may require pipeline adjustments
   - dbt models should be designed with schema evolution in mind

3. **Processing Windows**
   - Batch processing occurs on a monthly cadence
   - Pipeline should be idempotent to allow for reprocessing

### Infrastructure Limitations
1. **Cost Management**
   - BigQuery pricing is based on query volume and storage
   - Proper partitioning and clustering can reduce query costs
   - Consider usage of BigQuery flat-rate pricing for predictable costs

2. **Permissions and Security**
   - Least privilege principle for service accounts
   - Secure storage of credentials and secrets
   - Proper IAM configuration for resource access

3. **Deployment Considerations**
   - Local vs. cloud-hosted Kestra deployment trade-offs
   - Terraform state management and locking for team environments

## Dependencies

### External Dependencies
1. **Data Source**
   - AIS data availability and format consistency
   - Download endpoints for ZIP files
   - Potential rate limiting or access restrictions

2. **GCP Services**
   - Service availability and quotas
   - API version compatibility
   - Regional availability of services

### Internal Dependencies
1. **Component Dependencies**
   - Infrastructure must be provisioned before pipeline execution
   - Data must be in GCS before BigQuery loading
   - Staging tables must exist before dbt transformation

2. **Version Dependencies**
   - Terraform provider versions
   - dbt package versions
   - Kestra version compatibility

3. **Configuration Dependencies**
   - Environment variables
   - Service account credentials
   - Connection strings and endpoints

## Integration Points

1. **GCS to BigQuery**
   - Loading data from GCS to BigQuery using BigQuery's load API
   - Schema definition and enforcement during loading

2. **dbt to BigQuery**
   - dbt models creating and modifying BigQuery tables
   - Incremental loading strategies

3. **BigQuery to Looker Studio**
   - Direct connection from Looker Studio to BigQuery
   - Query optimization for dashboard performance

4. **Kestra to GCP Services**
   - Direct integration with GCS for file operations
   - Integration with BigQuery for data loading and querying
   - Service account authentication for secure access

## Data Mart Layer

The project now includes an additional data mart layer specifically designed for dashboard requirements:

1. **Purpose**
   - Pre-aggregate data for dashboard performance
   - Simplify dashboard queries
   - Optimize for specific visualization requirements

2. **Implementation**
   - dbt models for daily and monthly aggregations
   - Partition by date for efficient time-based filtering
   - Materialized as BigQuery tables for direct dashboard connection

3. **Dashboard Integration**
   - Direct connection from Looker Studio to mart tables
   - Simplified SQL queries for dashboard visualizations
   - Improved dashboard load time and responsiveness

This technical context document provides an overview of the technologies, setup requirements, constraints, and dependencies for the AIS data engineering project. It serves as a reference for understanding the technical landscape and considerations for development and deployment.
