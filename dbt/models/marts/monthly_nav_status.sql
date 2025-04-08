{{ config(
    materialized = 'table',
    partition_by = {
        "field": "month_start_date",
        "data_type": "date"
    }
) }}

/*
    Mart model for monthly navigational status aggregation.
    This model aggregates vessel counts by navigational status for each month.
    Used for the monthly navigational status distribution dashboard.
*/

WITH monthly_aggregation AS (
    SELECT
        -- Create a proper date for the first day of each month for partitioning
        DATE_TRUNC(event_date, MONTH) AS month_start_date,
        
        -- Extract year and month for display
        EXTRACT(YEAR FROM event_date) AS year,
        EXTRACT(MONTH FROM event_date) AS month,
        
        -- Format as YYYY-MM for easy display in dashboards
        FORMAT_DATE('%Y-%m', event_date) AS year_month,
        
        -- Use the original navigational status field
        navigational_status,
        
        -- Count distinct vessels per status category per month
        COUNT(DISTINCT mmsi) AS vessel_count,
        
        -- Daily average of distinct vessels
        ROUND(COUNT(DISTINCT mmsi) / COUNT(DISTINCT event_date), 2) AS avg_daily_vessels,
        
        -- Count total records per status category per month
        COUNT(*) AS record_count,
        
        -- Count distinct days with data in this month
        COUNT(DISTINCT event_date) AS days_count,
        
        -- Include movement status category for additional filtering options
        movement_status,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS generated_at
    FROM {{ ref('ais_curated') }}
    WHERE 
        -- Filter out records with null or invalid navigational status
        navigational_status IS NOT NULL
        AND navigational_status != ''
        
        -- Add any additional data quality filters here
        AND valid_coordinates = TRUE
    
    GROUP BY 
        month_start_date,
        year,
        month,
        year_month,
        navigational_status,
        movement_status
)

SELECT * FROM monthly_aggregation
