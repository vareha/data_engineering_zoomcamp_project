# Metabase Dashboard Implementation Guide

## Introduction
This guide provides detailed instructions for implementing self-hosted Metabase dashboards based on the dbt mart models we've created for AIS data analysis. We'll set up Metabase using Docker and create two main visualizations:
1. A pie chart showing daily navigational status distribution
2. A time series visualization showing monthly navigational status trends over time

## Prerequisites
- Docker and Docker Compose installed on the host system
- Access to BigQuery project (`de-zoomcamp-project-455806`)
- The dbt models have been successfully run and data is available in BigQuery
- A service account key file with BigQuery access permissions

## Step 1: Set Up Self-Hosted Metabase with Docker

1. Create a directory for Metabase configuration:
```bash
mkdir -p metabase/data
```

2. Create a Docker Compose file for Metabase:
```bash
touch metabase/docker-compose.yml
```

3. Add the following configuration to the Docker Compose file:
```yaml
version: '3'
services:
  metabase:
    image: metabase/metabase:latest
    container_name: metabase
    ports:
      - "3000:3000"
    volumes:
      - ./data:/metabase-data
    environment:
      - MB_DB_FILE=/metabase-data/metabase.db
      - JAVA_TIMEZONE=Europe/Lisbon
    restart: unless-stopped
```

4. Start Metabase:
```bash
cd metabase
docker-compose up -d
```

5. Access Metabase setup:
   - Open your browser and navigate to http://localhost:3000
   - Follow the initial setup wizard:
     - Create an admin account
     - Set basic preferences

## Step 2: Connect Metabase to BigQuery

1. From the Metabase admin interface, navigate to Admin > Databases > Add database

2. Select "Google BigQuery" as the database type

3. Configure the connection:
   - **Name**: AIS Data Warehouse
   - **Dataset ID**: Specify your BigQuery dataset ID (e.g., `marts`)
   - **Service Account JSON**: Copy the contents of your service account key file
   - **Project ID**: `de-zoomcamp-project-455806`

4. Under "Advanced options":
   - Enable "Use data warehouse local timezone"
   - Set an appropriate sync frequency (e.g., 6 hours)
   - Enable "Refingerprint and scan on schedule"
   - Leave other settings as default

5. Click "Save" to complete the connection

6. Metabase will begin scanning the database and synchronizing metadata

## Step 3: Verify Data Access

1. Once synchronization is complete, go to "Browse Data"
2. You should see your BigQuery dataset and dbt-created tables:
   - `daily_navigational_status`
   - `monthly_navigational_status`
3. Explore the tables to verify data access:
   - Click on each table
   - Review sample data and field types
   - Ensure date/timestamp fields are properly recognized

## Step 4: Create a New Dashboard

1. Click on "Dashboards" in the top navigation
2. Click "Create a dashboard"
3. Name it "AIS Navigational Status Analysis"
4. Add a description: "Analysis of ship navigational status from AIS data"
5. Click "Create"

## Step 5: Create Daily Navigational Status Pie Chart

1. In your dashboard, click "Add a question"
2. Select "Custom question"
3. Configure data source:
   - Select your database and the `daily_navigational_status` table
4. Set up the query:
   - Under "Summarize", select "Group by" > "navigational_status"
   - Select "Sum of" > "percentage" for the metric
5. Click "Visualize" and change the visualization type to "Pie chart"
6. Configure visualization settings:
   - Title: "Daily Navigational Status Distribution"
   - Labels: Show values and percentages
   - Colors: Select a diverse color palette for different statuses
7. Add filter:
   - Click "Filter" button
   - Add "Date" filter type
   - Set default to "Last 30 days" or appropriate timeframe
8. Save the question with a descriptive name (e.g., "Daily Nav Status Distribution")
9. Add to dashboard

## Step 6: Create Monthly Navigational Status Time Series

1. Click "Add a question" in your dashboard
2. Select "Custom question"
3. Configure data source:
   - Select your database and the `monthly_navigational_status` table
4. Set up the query:
   - Under "Pick the metric you want to see", select "Sum of" > "percentage"
   - Under "Pick a column to group by", select "month_start_date"
   - Add a second grouping by "navigational_status"
5. Click "Visualize" and select "Stacked area chart" or "Stacked bar chart"
6. Configure visualization settings:
   - Title: "Monthly Navigational Status Trends"
   - X-axis: month_start_date (ensure it's set to time series)
   - Y-axis: Format as percentage
   - Series: Group by navigational_status
   - Colors: Use the same color palette as the pie chart
7. Add filter:
   - Add date range filter for month_start_date
   - Set default to last 12 months or appropriate timeframe
8. Save the question with a descriptive name (e.g., "Monthly Nav Status Trends")
9. Add to dashboard

## Step 7: Add Text Cards with Context

1. In the dashboard, click "Add a card" and select "Text"
2. Add a title card with dashboard explanation:
```
# AIS Navigational Status Analysis

This dashboard presents analysis of ship navigational status data from Automatic Identification System (AIS) transmissions.

The pie chart shows the distribution of different navigational statuses for a specific day.
The time series chart shows how this distribution changes over months.
```

3. Add another text card with status code explanations:
```
## Navigational Status Codes

- 0: Under way using engine
- 1: At anchor
- 2: Not under command
- 3: Restricted maneuverability
- 4: Constrained by draft
- 5: Moored
- 6: Aground
- 7: Engaged in fishing
- 8: Under way sailing
```

## Step 8: Add Summary Metrics

1. Create number cards for key metrics:
   - Total records across all statuses
   - Most common navigational status
   - Percentage of records with valid MMSI
2. For each metric:
   - Create a new question with the appropriate SQL aggregation
   - Set visualization to "Number"
   - Configure formatting (e.g., show as percentage, appropriate decimals)
   - Add to dashboard
3. Arrange metrics in a row at the top of the dashboard

## Step 9: Configure Dashboard Filters

1. In the dashboard edit mode, click "Add a filter"
2. Create a date filter:
   - Name: "Date Range"
   - Type: "Date"
   - Default value: Last 30 days
3. Wire this filter to both visualizations:
   - Connect to the date field in the daily status visualization
   - Connect to the month_start_date in the monthly status visualization
4. Add a navigational status filter:
   - Name: "Navigational Status"
   - Type: "Category"
   - Default: All values
5. Wire this filter to both visualizations

## Step 10: Arrange Dashboard Layout

1. Resize and arrange cards in a logical order:
   - Text explanation at the top
   - Summary metrics in a row
   - Daily and monthly visualizations side by side or stacked
   - Status code explanation at the bottom
2. Use the drag-and-drop interface to position elements
3. Save the dashboard layout

## Step 11: Set Up Refresh Schedule

1. Go to Admin > Tools > Task History
2. Ensure the data sync task is running properly
3. Adjust sync schedule if needed (Admin > Databases > your database)
4. Consider enabling "Cache query results" for better performance

## Step 12: Share and Access Control

1. Click on "Sharing and embedding" in the dashboard
2. Select appropriate sharing options:
   - Public link (if needed)
   - Specific Metabase users/groups
3. Configure permissions in Admin > Permissions:
   - Set up user groups if needed
   - Grant appropriate access to dashboards and underlying data

## Step 13: Create a Dashboard Collection

1. Go to Collections in the top navigation
2. Create a new collection called "AIS Data Analysis"
3. Move your dashboard to this collection
4. Set appropriate collection permissions

## Technical Implementation Details

### BigQuery SQL for Daily Visualization

```sql
SELECT
  date,
  navigational_status,
  record_count,
  total_daily_records,
  percentage
FROM
  `de-zoomcamp-project-455806.marts.daily_navigational_status`
```

### BigQuery SQL for Monthly Visualization

```sql
SELECT
  month_start_date,
  year,
  month,
  navigational_status,
  record_count,
  total_monthly_records,
  percentage
FROM
  `de-zoomcamp-project-455806.marts.monthly_navigational_status`
ORDER BY
  month_start_date, navigational_status
```

## Testing and Validation

Before finalizing the dashboard:

1. Test all filters to ensure they work as expected
2. Verify that data matches expected values from BigQuery
3. Check performance with different date ranges
4. Test from different browsers and devices
5. Get feedback from potential users

## Maintenance

1. Monitor Metabase logs for any issues:
   ```bash
   docker logs metabase
   ```

2. Update Metabase when new versions are available:
   ```bash
   cd metabase
   docker-compose pull
   docker-compose up -d
   ```

3. Back up Metabase data periodically:
   ```bash
   cp -r metabase/data /backup/metabase_data_$(date +%Y%m%d)
   ```

## Troubleshooting

### Connection Issues
- Verify service account has proper BigQuery permissions
- Check network connectivity between Metabase container and GCP
- Review Metabase logs for connection errors

### Performance Issues
- Consider materializing complex queries as views
- Adjust caching settings in Metabase
- Verify BigQuery partition pruning is working correctly

### Visualization Issues
- For date formatting issues, verify timezone settings
- For data discrepancies, compare raw BigQuery results with Metabase
- For rendering problems, try alternative chart types

---

This implementation guide provides a comprehensive approach to setting up self-hosted Metabase dashboards for AIS data analysis. The resulting dashboards will enable users to explore navigational status patterns both daily (via pie chart) and over time (via time series), providing valuable insights into maritime traffic behavior.
