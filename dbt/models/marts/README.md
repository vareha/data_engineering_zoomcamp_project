# Data Marts for AIS Dashboard Visualizations

This directory contains dbt models specifically designed to power dashboard visualizations for AIS data analysis. The models aggregate and pre-compute data to optimize dashboard performance and simplify visualization creation.

## Models Overview

### 1. `daily_nav_status`

**Purpose**: Powers the pie chart visualization showing navigational status distribution for a selected day.

**Key Features**:
- Aggregates data by day and navigational status
- Counts distinct vessels and total records for each status
- Includes movement status categorization for additional filtering
- Partitioned by event_date for efficient filtering

**Usage in Dashboard**:
- Connect this table directly to Looker Studio
- Filter by event_date to view specific days
- Use navigational_status as dimension and vessel_count as metric in pie chart
- Optional: Add movement_status as a filter control

### 2. `monthly_nav_status`

**Purpose**: Powers the time series visualization showing navigational status distribution trends over months.

**Key Features**:
- Aggregates data by month and navigational status
- Provides year, month, and formatted year_month fields for easy time dimension handling
- Includes metrics like vessel count, average daily vessels, and days with data
- Partitioned by month_start_date for efficient time-based queries

**Usage in Dashboard**:
- Connect this table directly to Looker Studio
- Use year_month as time dimension on x-axis
- Use navigational_status as series/color dimension
- Use vessel_count or avg_daily_vessels as metric on y-axis
- Can be visualized as line chart, bar chart, or stacked area chart

## Dashboard Implementation

### Required Dashboard Components

1. **Daily Navigational Status Pie Chart**:
   - Data source: `daily_nav_status`
   - Chart type: Pie or Donut chart
   - Date selector control connected to event_date
   - Dimensions: navigational_status
   - Metrics: vessel_count (or record_count)

2. **Monthly Navigational Status Distribution**:
   - Data source: `monthly_nav_status`
   - Chart type: Line chart, Bar chart, or Stacked area chart
   - Time dimension: year_month
   - Series: navigational_status
   - Metrics: vessel_count or avg_daily_vessels

### Optional Dashboard Enhancements

- Add movement_status as a filter control for both visualizations
- Include record_count alongside vessel_count for comparison
- Add a data quality indicator (% of days with data in each month)
- Create a combined dashboard with both visualizations and shared controls

## Data Quality Considerations

Both models include basic data quality filtering:
- Filter out NULL or empty navigational_status
- Only include records with valid_coordinates=TRUE
- Additional quality filters may be added as needed

## Performance Optimization

These models are materialized as tables and use partitioning to ensure efficient querying:
- `daily_nav_status` is partitioned by event_date
- `monthly_nav_status` is partitioned by month_start_date

This approach ensures dashboard queries only scan the relevant data partitions, improving performance and reducing BigQuery costs.
