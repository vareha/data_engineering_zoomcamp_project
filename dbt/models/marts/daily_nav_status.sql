{{ config(
    materialized = 'table',
    partition_by = {
        "field": "event_date",
        "data_type": "date"
    }
) }}

/*
    Mart model for daily navigational status aggregation.
    This model aggregates vessel counts by navigational status for each day.
    Used for the navigational status pie chart dashboard.
*/

WITH daily_aggregation AS (
    SELECT
        -- Use date as the partition field
        event_date,
        
        -- Use the original navigational status field
        navigational_status,
        
        -- Count distinct vessels per status category
        COUNT(DISTINCT mmsi) AS vessel_count,
        
        -- Count total records per status category
        COUNT(*) AS record_count,
        
        -- Percentage calculation will be done in the dashboard or here as needed
        -- Add additional aggregated metrics as needed
        
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
        event_date,
        navigational_status,
        movement_status
)

SELECT * FROM daily_aggregation
