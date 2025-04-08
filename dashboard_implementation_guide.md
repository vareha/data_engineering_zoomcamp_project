# Dashboard Implementation Guide

This guide provides step-by-step instructions for implementing the AIS data dashboards using dbt and Looker Studio.

## Prerequisites

- GCP project with BigQuery set up
- Service account with BigQuery access
- Kestra workflow successfully running and loading data to BigQuery
- dbt CLI installed locally (or dbt Cloud account configured)
- Environment variables set for GCP access:
  - `GCP_PROJECT_ID`
  - `GCP_LOCATION`
  - `GOOGLE_APPLICATION_CREDENTIALS`

## Step 1: Run dbt Models

### 1.1 Install dbt Dependencies

```bash
cd data_engineering_zoomcamp_project/dbt
dbt deps
```

### 1.2 Test dbt Connection

```bash
dbt debug
```

Ensure that the connection to BigQuery is working properly before proceeding.

### 1.3 Run dbt Models

To run all models (staging, curated, and marts):

```bash
dbt run
```

To run only the mart models for dashboards:

```bash
dbt run --select marts.*
```

### 1.4 Test dbt Models

```bash
dbt test
```

This will run the tests defined in the schema.yml files to ensure data quality.

### 1.5 Generate dbt Documentation (Optional)

```bash
dbt docs generate
dbt docs serve
```

This will create and serve interactive documentation for your dbt models.

## Step 2: Create Looker Studio Dashboards

### 2.1 Access Looker Studio

1. Go to [Looker Studio](https://lookerstudio.google.com/)
2. Sign in with your Google account (same account with access to your GCP project)
3. Click "Create" and select "Report"

### 2.2 Connect to BigQuery Data Sources

#### Daily Navigational Status Data Source

1. Select "BigQuery" as the data source type
2. Select your GCP project
3. Select the "marts" dataset
4. Select the "daily_nav_status" table
5. Click "Connect"

#### Monthly Navigational Status Data Source

1. Click "Add data" in the report
2. Select "BigQuery" as the data source type
3. Select your GCP project
4. Select the "marts" dataset
5. Select the "monthly_nav_status" table
6. Click "Connect"

### 2.3 Create Daily Navigational Status Pie Chart

1. Add a date range control:
   - From the "Add a control" menu, select "Date range"
   - Configure it to filter based on "event_date"

2. Add a pie chart:
   - From the "Add a chart" menu, select "Pie chart"
   - Set "Dimension" to "navigational_status"
   - Set "Metric" to "vessel_count"
   - Link this chart to the daily_nav_status data source
   - Connect it to the date range control

3. Format the pie chart:
   - Add a meaningful title (e.g., "Vessel Navigational Status Distribution")
   - Configure colors for better visualization
   - Add data labels showing percentages

### 2.4 Create Monthly Navigational Status Visualization

1. Add a time series chart:
   - From the "Add a chart" menu, select "Time series chart"
   - Set "Time dimension" to "year_month"
   - Set "Breakdown dimension" to "navigational_status"
   - Set "Metric" to "vessel_count"
   - Link this chart to the monthly_nav_status data source

2. Format the time series chart:
   - Add a meaningful title (e.g., "Monthly Navigational Status Trends")
   - Configure colors to match the pie chart
   - Adjust line thickness and style as needed
   - Configure the legend position and format

### 2.5 Add Dashboard Controls (Optional)

1. Add a filter for movement_status:
   - From the "Add a control" menu, select "Drop-down list"
   - Configure it to filter based on "movement_status"
   - Apply it to both charts

2. Add a metric selector:
   - From the "Add a control" menu, select "Drop-down list"
   - Configure it to select between "vessel_count" and "record_count"
   - Connect it to both charts using calculated fields

### 2.6 Finalize Dashboard Layout

1. Arrange charts and controls in a logical layout
2. Add text elements for titles and explanations
3. Add your logo and any required disclaimers
4. Configure the theme and color scheme for consistency

### 2.7 Share the Dashboard

1. Click the "Share" button in the top-right corner
2. Configure access permissions
3. Choose whether to enable downloading or copying
4. Share the link with stakeholders

## Step 3: Schedule Regular Updates

### 3.1 Set Up Regular dbt Runs

To ensure your dashboard data stays current, schedule regular dbt runs after the Kestra workflow completes:

1. Add a dbt run step to your Kestra workflow (recommended), or
2. Set up a cron job to run dbt on a regular schedule, or
3. Use dbt Cloud for scheduled runs

### 3.2 Monitor Data Freshness

Add a "Last Updated" timestamp to your dashboard:

1. In Looker Studio, add a text element
2. Use the "generated_at" field from your mart models
3. Format it as "Data updated: {date time}"

## Troubleshooting

### Common Issues and Solutions

1. **Missing data in dashboard:** 
   - Verify that the Kestra workflow ran successfully
   - Check dbt logs for any errors during model execution
   - Inspect the BigQuery tables to ensure data was loaded correctly

2. **Dashboard performance issues:**
   - Check query execution time in BigQuery
   - Consider further optimizing partitioning and clustering
   - Reduce date ranges or add more aggregation if needed

3. **Incorrect metrics:**
   - Validate the data in BigQuery using SQL queries
   - Ensure that the dbt transformations are working as expected
   - Check for data quality issues in the source data

For any other issues, check the dbt logs and BigQuery query history for errors.

## Next Steps

1. Consider implementing additional visualizations:
   - Geographic map of vessel positions
   - Vessel type distribution
   - Speed analysis by navigational status

2. Enhance your dashboard with advanced features:
   - Anomaly detection indicators
   - Trend comparison across time periods
   - Performance metrics and KPIs

3. Set up automated email reports or scheduled exports
