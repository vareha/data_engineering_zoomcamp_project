with staging as (

    select * from {{ ref('staging_ais_data') }}

),

-- Add row numbering to identify duplicate unique_row_id values
row_numbered as (
    select 
        *,
        ROW_NUMBER() OVER (PARTITION BY unique_row_id ORDER BY timestamp) as row_num
    from staging
),

-- Only keep the first occurrence of each unique_row_id
deduplicated as (
    select * 
    from row_numbered
    where row_num = 1
),

converted as (
    select
        unique_row_id,
        filename,
        -- Convert timestamp to proper datetime
        CAST(timestamp AS TIMESTAMP) as timestamp,
        type_of_mobile,
        -- Ensure MMSI is a string to handle leading zeros
        CAST(mmsi AS STRING) as mmsi,
        -- Ensure coordinates are proper floats and within valid ranges
        CASE 
            WHEN latitude >= -90 AND latitude <= 90 THEN latitude
            ELSE NULL 
        END as latitude,
        CASE 
            WHEN longitude >= -180 AND longitude <= 180 THEN longitude
            ELSE NULL 
        END as longitude,
        -- Clean up navigational status for consistency
        CASE
            WHEN navigational_status IS NULL THEN 'Unknown'
            WHEN TRIM(navigational_status) = '' THEN 'Unknown'
            ELSE navigational_status
        END as navigational_status,
        rot,
        -- Speed over ground - handle nulls or invalid values
        CASE
            WHEN sog < 0 THEN NULL
            ELSE sog
        END as sog,
        -- Course over ground - handle nulls or invalid values
        CASE
            WHEN cog < 0 OR cog > 360 THEN NULL
            ELSE cog
        END as cog,
        -- Heading - handle nulls or invalid values
        CASE
            WHEN heading < 0 OR heading > 360 THEN NULL
            ELSE heading
        END as heading,
        -- Ensure IMO is a string to handle leading zeros
        CASE
            WHEN imo IS NOT NULL THEN CAST(imo AS STRING)
            ELSE NULL
        END as imo,
        callsign,
        -- Clean up vessel name
        CASE
            WHEN name IS NULL THEN 'Unknown'
            WHEN TRIM(name) = '' THEN 'Unknown'
            ELSE TRIM(name)
        END as name,
        ship_type,
        cargo_type,
        width,
        length,
        type_of_position_fixing_device,
        draught,
        destination,
        eta,
        data_source_type,
        size_a,
        size_b,
        size_c,
        size_d,
        -- Add a calculated total vessel length
        CASE
            WHEN size_a IS NOT NULL AND size_b IS NOT NULL THEN size_a + size_b
            WHEN length IS NOT NULL THEN length
            ELSE NULL
        END as calculated_length,
        -- Add a calculated total vessel width
        CASE
            WHEN size_c IS NOT NULL AND size_d IS NOT NULL THEN size_c + size_d
            WHEN width IS NOT NULL THEN width
            ELSE NULL
        END as calculated_width,
        -- Extract date components for easier filtering and aggregation
        EXTRACT(DATE FROM CAST(timestamp AS TIMESTAMP)) as date,
        EXTRACT(YEAR FROM CAST(timestamp AS TIMESTAMP)) as year,
        EXTRACT(MONTH FROM CAST(timestamp AS TIMESTAMP)) as month,
        EXTRACT(DAY FROM CAST(timestamp AS TIMESTAMP)) as day,
        EXTRACT(HOUR FROM CAST(timestamp AS TIMESTAMP)) as hour
    from deduplicated
),

-- Final output with additional data quality filters
final as (
    select
        *,
        -- Flag records with valid coordinates for geospatial analysis
        (latitude IS NOT NULL AND longitude IS NOT NULL) as has_valid_position,
        -- Flag records with valid vessel identification
        (mmsi IS NOT NULL) as has_valid_mmsi
    from converted
    -- Only include records with valid timestamps
    where timestamp IS NOT NULL
)

select * from final
