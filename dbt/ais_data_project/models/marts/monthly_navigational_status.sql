{{
    config(
        materialized = 'table',
        partition_by = {
            "field": "month_start_date",
            "data_type": "date",
            "granularity": "month"
        },
        cluster_by = ["navigational_status"]
    )
}}

with intermediate_data as (
    select 
        -- Create a date corresponding to the first day of the month for partitioning
        DATE(year, month, 1) as month_start_date,
        year,
        month,
        navigational_status,
        count(*) as record_count
    from {{ ref('int_ais_data') }}
    where has_valid_mmsi = true -- Only include valid records
    group by year, month, month_start_date, navigational_status
),

-- Calculate monthly totals for percentage calculation
monthly_totals as (
    select
        month_start_date,
        year,
        month,
        sum(record_count) as total_monthly_records
    from intermediate_data
    group by month_start_date, year, month
),

-- Calculate percentages for each navigational status by month
final as (
    select
        i.month_start_date,
        i.year,
        i.month,
        i.navigational_status,
        i.record_count,
        t.total_monthly_records,
        SAFE_DIVIDE(i.record_count, t.total_monthly_records) * 100 as percentage
    from intermediate_data i
    join monthly_totals t on i.month_start_date = t.month_start_date
)

select * from final
