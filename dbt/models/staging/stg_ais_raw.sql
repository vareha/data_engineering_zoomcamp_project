{{ config(
    materialized = 'view',
    schema = 'staging'
) }}

/*
    Staging model for AIS data.
    This model formats raw AIS data from the ais_data table
    with consistent data types and column names.
*/

WITH source_data AS (
    SELECT
        -- Handle timestamp parsing and timezone conversion
        PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', timestamp) AS event_ts,
        
        -- Vessel identification
        mmsi,
        type_of_mobile,
        
        -- Geospatial data
        CAST(latitude AS FLOAT64) AS latitude,
        CAST(longitude AS FLOAT64) AS longitude,
        
        -- Navigation data
        navigational_status,
        CAST(rot AS FLOAT64) AS rate_of_turn,
        CAST(sog AS FLOAT64) AS speed_over_ground,
        
        -- Add any additional fields from the source data
        -- cog as course_over_ground,
        -- heading,
        -- etc.

        -- Add data lineage metadata
        _TABLE_SUFFIX AS data_partition, -- If using partitioned tables
        CURRENT_TIMESTAMP() AS ingestion_timestamp
        
    FROM {{ source('ais_data', 'ais_data') }}
    -- Add any basic filtering if needed
    -- WHERE mmsi IS NOT NULL
)

SELECT * FROM source_data
