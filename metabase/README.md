# AIS Data Project - Metabase Dashboards

## Overview
This directory contains configuration files and setup instructions for implementing self-hosted Metabase dashboards for the AIS data project. Metabase provides an interactive dashboard solution for visualizing the AIS navigational status data processed through our dbt models.

## Directory Structure
```
metabase/
├── docker-compose.yml        # Docker configuration for Metabase
├── setup_metabase.sh         # Setup script for easy installation
├── queries/                  # Example SQL queries for dashboard visualizations
│   ├── daily_navigational_status.sql   # Query for daily status pie chart 
│   ├── monthly_navigational_status.sql # Query for monthly status time series
│   └── summary_metrics.sql             # Query for dashboard summary metrics
└── README.md                 # This file
```

## Prerequisites
- Docker and Docker Compose installed
- Access to BigQuery with the AIS data project
- Google Cloud Service Account with BigQuery permissions
- dbt models have been successfully run (daily_navigational_status and monthly_navigational_status)

## Quick Start
1. Run the setup script to initialize Metabase:
   ```bash
   cd metabase
   ./setup_metabase.sh
   ```

2. Access Metabase at http://localhost:3000 and complete the initial setup.

3. Connect Metabase to BigQuery using your service account credentials.

4. Create dashboards following the detailed instructions in `../metabase_implementation_guide.md`.

## Dashboard Components
The dashboards will include:

1. **Daily Navigational Status Distribution**
   - Pie chart showing the percentage distribution of navigational statuses for a specific day
   - Based on `daily_navigational_status` dbt model
   - Uses `queries/daily_navigational_status.sql` as a reference

2. **Monthly Navigational Status Trends**
   - Time series visualization showing how navigational status distributions change over time
   - Based on `monthly_navigational_status` dbt model
   - Uses `queries/monthly_navigational_status.sql` as a reference

3. **Summary Metrics**
   - Total records processed
   - Most common navigational status
   - Days with data
   - Uses `queries/summary_metrics.sql` as a reference

## Data Refresh
- Metabase connects directly to BigQuery
- Data refreshes are controlled by:
  1. dbt model refresh frequency
  2. Metabase database sync settings (configurable in Admin > Databases)

## Additional Resources
- [Metabase Documentation](https://www.metabase.com/docs/latest/)
- [Metabase BigQuery Connection](https://www.metabase.com/docs/latest/databases/connections/bigquery)
- For detailed implementation instructions, see `../metabase_implementation_guide.md`

## Troubleshooting
- If Metabase fails to start, check Docker logs: `docker logs metabase`
- For BigQuery connection issues, verify your service account has proper permissions
- For visualization issues, see the troubleshooting section in the implementation guide
