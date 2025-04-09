with 

source as (

    select * from {{ source('staging', 'ais_data') }}

),

renamed as (

    select
        unique_row_id,
        filename,
        timestamp,
        type_of_mobile,
        mmsi,
        latitude,
        longitude,
        navigational_status,
        rot,
        sog,
        cog,
        heading,
        imo,
        callsign,
        name,
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
        size_d

    from source

)

select * from renamed
