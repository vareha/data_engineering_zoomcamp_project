# Product Context

## Project Purpose
This data engineering project exists to process and analyze Automatic Identification System (AIS) data from ships. The AIS system is a tracking system used on ships for identifying and locating vessels by electronically exchanging data with other nearby ships, AIS base stations, and satellites. This project provides a complete data engineering pipeline to transform raw AIS tracking data into actionable insights.

## Problems Solved
1. **Data Accessibility**: Transforms raw, compressed AIS data into queryable, structured formats
2. **Processing Efficiency**: Automates extraction and transformation of monthly data dumps
3. **Analysis Capabilities**: Enables querying and visualization of ship movement patterns
4. **Scalability**: Handles large volumes of maritime tracking data using cloud resources
5. **Reproducibility**: Ensures consistent environment setup and deployment

## How It Works

### Data Flow
1. **Ingestion**: Monthly AIS data is downloaded as ZIP files containing CSV data
2. **Extraction**: CSV files are extracted from ZIP archives
3. **Storage**: Raw data is stored in Google Cloud Storage (GCS)
4. **Loading**: Data is loaded into BigQuery staging tables
5. **Transformation**: dbt is used to clean, organize, and structure the data
6. **Visualization**: Transformed data is visualized in Looker Studio

### Orchestration
- Airflow DAG manages the entire pipeline workflow
- Each step is executed in sequence with appropriate error handling
- The pipeline can be triggered manually or scheduled to run periodically

### Infrastructure
- All cloud resources are provisioned using Terraform
- Local development environment setup is streamlined with Makefile
- The entire pipeline can be reproduced with minimal manual intervention

## User Experience Goals

### Data Engineers
- Simple setup process with clear documentation
- Easy maintenance and monitoring of the pipeline
- Ability to extend or modify transformation logic

### Data Analysts
- Clean, well-structured data in BigQuery
- Intuitive dashboard for exploring AIS data patterns
- Ability to drill down into specific time periods or vessel categories

### Project Stakeholders
- Clear visibility into ship movement patterns
- Insights into maritime traffic distribution
- Temporal analysis of shipping activity

## Expected Outcomes
1. **Functional Pipeline**: A reliable, automated workflow for processing AIS data
2. **Queryable Dataset**: Clean, partitioned data in BigQuery optimized for analysis
3. **Visual Dashboard**: Interactive visualizations showing categorical and temporal distributions
4. **Reproducible Infrastructure**: IaC approach ensuring consistent deployment
5. **Maintainable Codebase**: Well-structured project with clear documentation

This product context document outlines the purpose, workflow, and expected outcomes of the data engineering project, providing a foundation for understanding why and how we're building this solution.
