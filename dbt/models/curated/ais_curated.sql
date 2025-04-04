{{ config(
    materialized = 'table',
    partition_by = {
        "field": "event_ts",
        "data_type": "timestamp",
        "granularity": "day"
    },
    cluster_by = ["mmsi"]
) }}

/*
    Curated model for AIS data.
    This model transforms and enriches the staged data.
    It includes:
    - Partitioning by event timestamp for query performance
    - Clustering by MMSI (vessel identifier) for faster vessel-specific queries
    - Enriched data with derived fields and cleaned values
*/

WITH cleaned_data AS (
    SELECT
        -- Timestamp field used for partitioning
        event_ts,
        
        -- Primary vessel identifier
        mmsi,
        type_of_mobile,
        
        -- Location data
        latitude,
        longitude,
        
        -- Create a geography point for spatial analysis
        ST_GEOGPOINT(longitude, latitude) AS location_point,
        
        -- Navigation data
        navigational_status,
        rate_of_turn,
        speed_over_ground,
        
        -- Data quality dimensions
        -- Flag records with potentially invalid coordinates
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180) AS valid_coordinates,
        
        -- Data lineage
        data_partition,
        ingestion_timestamp
    FROM {{ ref('stg_ais_raw') }}
    -- Filter out records with invalid timestamps
    WHERE event_ts IS NOT NULL
)

-- Add derivative dimensions and metrics
SELECT
    -- Core dimensions
    event_ts,
    DATE(event_ts) AS event_date,
    EXTRACT(YEAR FROM event_ts) AS year,
    EXTRACT(MONTH FROM event_ts) AS month,
    EXTRACT(DAY FROM event_ts) AS day,
    EXTRACT(HOUR FROM event_ts) AS hour,
    
    -- Vessel identifiers
    mmsi,
    type_of_mobile,
    
    -- Categorize vessel type for analytical purposes
    CASE
        WHEN type_of_mobile LIKE '%Passenger%' THEN 'Passenger'
        WHEN type_of_mobile LIKE '%Cargo%' THEN 'Cargo'
        WHEN type_of_mobile LIKE '%Tanker%' THEN 'Tanker'
        WHEN type_of_mobile LIKE '%Fishing%' THEN 'Fishing'
        ELSE 'Other'
    END AS vessel_category,
    
    -- Location data
    latitude,
    longitude,
    location_point,
    
    -- Calculate if in territorial waters (example - replace with actual logic)
    -- This is a simplified example; real implementation would use more specific boundaries
    CASE
        WHEN ABS(latitude) < 12 THEN 'Territorial Waters'
        ELSE 'International Waters'
    END AS water_zone,
    
    -- Navigation data
    navigational_status,
    rate_of_turn,
    speed_over_ground,
    
    -- Categorize navigation status for analysis
    CASE 
        WHEN navigational_status LIKE '%Anchor%' THEN 'Anchored'
        WHEN navigational_status LIKE '%Moored%' THEN 'Moored'
        WHEN navigational_status IN ('Under way using engine', 'Under way sailing') THEN 'Moving'
        ELSE 'Other'
    END AS movement_status,
    
    -- Speed categories for analysis
    CASE
        WHEN speed_over_ground < 1 THEN 'Stationary'
        WHEN speed_over_ground BETWEEN 1 AND 5 THEN 'Slow'
        WHEN speed_over_ground BETWEEN 5 AND 15 THEN 'Medium'
        WHEN speed_over_ground > 15 THEN 'Fast'
        ELSE 'Unknown'
    END AS speed_category,
    
    -- Data quality and lineage fields
    valid_coordinates,
    data_partition,
    ingestion_timestamp,
    CURRENT_TIMESTAMP() AS curated_timestamp
FROM cleaned_data
