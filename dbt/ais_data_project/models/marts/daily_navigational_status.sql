{{
    config(
        materialized = 'table',
        partition_by = {
            "field": "date",
            "data_type": "date",
            "granularity": "day"
        },
        cluster_by = ["navigational_status"]
    )
}}

with intermediate_data as (
    select 
        date,
        navigational_status,
        count(*) as record_count
    from {{ ref('int_ais_data') }}
    where has_valid_mmsi = true -- Only include valid records
    group by date, navigational_status
),

-- Calculate daily totals for percentage calculation
daily_totals as (
    select
        date,
        sum(record_count) as total_daily_records
    from intermediate_data
    group by date
),

-- Calculate percentages for each navigational status by day
final as (
    select
        i.date,
        i.navigational_status,
        i.record_count,
        t.total_daily_records,
        SAFE_DIVIDE(i.record_count, t.total_daily_records) * 100 as percentage
    from intermediate_data i
    join daily_totals t on i.date = t.date
)

select * from final
