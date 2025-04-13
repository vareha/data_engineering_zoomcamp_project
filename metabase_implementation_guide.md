# Metabase Dashboard Implementation Guide

## Introduction
This guide provides detailed instructions for implementing Metabase dashboards based on the dbt mart models we've created for AIS data analysis. We'll create two main visualizations:
1. A pie chart showing daily navigational status distribution
2. A time series visualization showing monthly navigational status trends over time

## Prerequisites
- Docker and Docker Compose installed
- Access to Google Cloud Console and the BigQuery project
- The dbt models have been successfully run and data is available in BigQuery
- Service account JSON file with BigQuery access permissions
- Metabase running locally (can be started with `make metabase-up`)

## Step 1: Access Metabase

1. Start Metabase using the provided command:
   ```
   make metabase-up
   ```

2. Open your web browser and navigate to [http://localhost:3000](http://localhost:3000)

3. Complete the initial setup when accessing Metabase for the first time:
   - Create an admin account with your email and password
   - Add your organization name
   - Choose data collection preferences

## Step 2: Connect to BigQuery Data Source

1. In Metabase, navigate to the Admin settings (gear icon in the top right)
2. Select "Databases" from the admin panel
3. Click "Add database"
4. Configure BigQuery connection:
   - Display name: "AIS Data BigQuery"
   - Database type: Google BigQuery
   - Dataset ID: Your BigQuery dataset (e.g., "ais_data" or "marts")
   - Service account JSON: Upload or paste your service account JSON content
   - Advanced options:
     - Set "Use JSON Query" to "Yes"
     - Ensure "Include User ID and Query Hash in queries" is set to "No" (for better query cache performance)
5. Click "Save" and wait for Metabase to sync with your BigQuery database
6. Once connected, you can go to "Browse Data" to see your tables

## Step 3: Create Daily Navigational Status Pie Chart

1. From the Metabase homepage, click "New" and select "Question"
2. Choose your BigQuery database and select the "daily_navigational_status" table
3. Click the "Visualization" button at the bottom
4. Choose "Pie chart" as the visualization type
5. Configure the pie chart:
   - "Group by": navigational_status
   - "Summarize": percentage or record_count
6. Apply filters if needed:
   - Add a filter on "date" to select a specific date range
7. Customize the appearance:
   - Click the "Settings" gear icon
   - Set an appropriate title: "Daily Navigational Status Distribution"
   - Adjust colors, labels, and legend settings
8. Click "Save" and name your question "Daily Navigational Status Distribution"

## Step 4: Create Monthly Navigational Status Time Series

1. From the Metabase homepage, click "New" and select "Question"
2. Choose your BigQuery database and select the "monthly_navigational_status" table
3. Click the "Visualization" button
4. Choose "Line chart" or "Bar chart" as the visualization type
5. Configure the chart:
   - "X-axis": month_start_date
   - "Y-axis": percentage or record_count
   - "Group by": navigational_status
6. Apply filters if needed:
   - Add a filter on "month_start_date" to select a specific period
7. Customize the appearance:
   - Click the "Settings" gear icon
   - Set an appropriate title: "Monthly Navigational Status Trends"
   - Adjust colors, axes, and legend settings
8. Click "Save" and name your question "Monthly Navigational Status Trends"

## Step 5: Create a Dashboard

1. From the Metabase homepage, click "New" and select "Dashboard"
2. Name your dashboard "AIS Navigational Status Analysis"
3. Add the questions you created:
   - Click "Add a question"
   - Select "Daily Navigational Status Distribution"
   - Click "Add question"
   - Repeat for "Monthly Navigational Status Trends"
4. Resize and arrange the visualizations as needed
5. Add a text card to provide context:
   - Click "Add a text card"
   - Add a description like:
   ```
   # AIS Navigational Status Analysis

   This dashboard presents analysis of ship navigational status data from Automatic Identification System (AIS) transmissions.

   - The pie chart shows the distribution of different navigational statuses for a specific day.
   - The time series chart shows how this distribution changes over months.

   Common navigational statuses include:
   - Under way using engine (0)
   - At anchor (1)
   - Not under command (2)
   - Restricted maneuverability (3)
   - Constrained by draft (4)
   - Moored (5)
   - Aground (6)
   - Engaged in fishing (7)
   - Under way sailing (8)
   ```
6. Click "Save"

## Step 6: Add Interactive Filters

1. From your dashboard, click the "Pencil" icon to enter edit mode
2. Click "Add a filter" at the top right
3. Select "Time" filter type
4. Map the filter to the date/timestamp fields in your questions:
   - For "Daily Navigational Status Distribution", map to the "date" field
   - For "Monthly Navigational Status Trends", map to the "month_start_date" field
5. Click "Done"
6. Add another filter for "Category":
   - Select "Category" filter type
   - Map it to the "navigational_status" field in both questions
7. Save your dashboard

## Step 7: Add Summary Metrics using SQL Questions

1. From the Metabase homepage, click "New" and select "Question"
2. Choose "Native query" (SQL) as the input method
3. Create a SQL query for total counts:
   ```sql
   SELECT
     SUM(record_count) as total_records,
     COUNT(DISTINCT date) as days_with_data,
     -- Most common status by percentage
     ARRAY_AGG(navigational_status ORDER BY percentage DESC LIMIT 1)[OFFSET(0)] as most_common_status
   FROM
     `your-project-id.marts.daily_navigational_status`
   ```
4. Run the query and select "Scalar" visualization for each metric
5. Save this question as "AIS Summary Metrics"
6. Add these metrics to your dashboard:
   - Edit the dashboard
   - Add the "AIS Summary Metrics" question
   - Choose "Just the number" visualization for each summary value

## Step 8: Optimize Performance

1. Navigate to Admin > Settings > Performance
2. Adjust cache settings:
   - Set question caching to an appropriate duration (e.g., 24 hours)
   - Enable dashboard caching
3. Return to your dashboard and click the clock icon to set a dashboard refresh schedule:
   - Set to refresh daily or at an appropriate frequency
4. Consider adding materialized views in BigQuery for frequently queried data

## Step 9: Share the Dashboard

1. Click the "Share" button on your dashboard
2. You can:
   - Copy a public link (if you've enabled public sharing in Admin settings)
   - Add specific Metabase users who should have access
   - Schedule regular email updates to stakeholders
   - Export the dashboard as PDF/PNG for sharing

## Advanced Customization

### Using Custom SQL

For more advanced visualizations, you can use custom SQL instead of the table interface:

1. Create a new question with "Native query" (SQL)
2. Use SQL like this for the daily distribution:
   ```sql
   SELECT
     date,
     navigational_status,
     percentage
   FROM
     `your-project-id.marts.daily_navigational_status`
   WHERE
     date BETWEEN DATETIME_SUB(CURRENT_DATE(), INTERVAL 30 DAY) AND CURRENT_DATE()
   ORDER BY
     date, percentage DESC
   ```
3. For monthly trends, use:
   ```sql
   SELECT
     month_start_date,
     navigational_status,
     percentage
   FROM
     `your-project-id.marts.monthly_navigational_status`
   ORDER BY
     month_start_date, navigational_status
   ```

### Creating a Map Visualization

If your AIS data contains geographical information, you can create a map visualization:

1. Create a new question selecting the staging_ais_data table
2. Filter to a specific date range to limit the number of points
3. Choose "Map" visualization
4. Set "Latitude" and "Longitude" as the location fields
5. Use "navigational_status" as a color dimension
6. Save and add to your dashboard

## Troubleshooting

### BigQuery Connection Issues

If you encounter connection issues:
1. Verify your service account has the correct permissions:
   - BigQuery Data Viewer (roles/bigquery.dataViewer)
   - BigQuery Job User (roles/bigquery.jobUser)
2. Check that your service account JSON is formatted correctly
3. Ensure your project ID and dataset names are correct
4. Try refreshing the Metabase metadata:
   - Admin > Databases > Your database > Sync database schema now

### Visualization Problems

1. For charts not displaying correctly:
   - Check your data for unexpected NULL values
   - Verify date/timestamp formatting is consistent
   - Ensure your aggregations make sense (e.g., summing percentages might not be valid)
2. For slow-loading visualizations:
   - Consider adding filters to limit data volume
   - Check if your dbt models are optimized with appropriate partitioning
   - Consider creating materialized views for complex calculations

### Missing Data

If data is missing in your visualizations:
1. Verify the dbt models ran successfully
2. Check if the date ranges in your filters exclude relevant data
3. Ensure the query is not hitting BigQuery data staleness issues
4. Refresh the Metabase data model:
   - Admin > Databases > Your database > Sync database schema now

## Maintenance

To keep your dashboard updated and performing well:

1. Schedule regular data refresh times
2. Monitor query performance in BigQuery's audit logs 
3. Update dashboard filters as new data arrives
4. Consider archiving or partitioning older data if performance degrades

---

This implementation guide provides a comprehensive approach to creating effective Metabase dashboards for AIS data analysis. The resulting dashboards will enable users to explore navigational status patterns both daily (via pie chart) and over time (via time series), providing valuable insights into maritime traffic behavior.
