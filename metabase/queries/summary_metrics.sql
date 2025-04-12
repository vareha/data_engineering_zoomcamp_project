-- Summary Metrics for Dashboard
-- This query creates the summary cards for the dashboard

-- 1. Most common navigational status
WITH most_common_status AS (
  SELECT
    navigational_status,
    SUM(record_count) as total_count,
    RANK() OVER (ORDER BY SUM(record_count) DESC) as status_rank
  FROM
    `de-zoomcamp-project-455806.marts.daily_navigational_status`
  WHERE
    date BETWEEN {{start_date}} AND {{end_date}}
  GROUP BY
    navigational_status
),

-- 2. Total vessel records
total_records AS (
  SELECT
    SUM(record_count) as all_records
  FROM
    `de-zoomcamp-project-455806.marts.daily_navigational_status`
  WHERE
    date BETWEEN {{start_date}} AND {{end_date}}
),

-- 3. Total days with data
days_with_data AS (
  SELECT
    COUNT(DISTINCT date) as day_count
  FROM
    `de-zoomcamp-project-455806.marts.daily_navigational_status`
  WHERE
    date BETWEEN {{start_date}} AND {{end_date}}
)

-- Combine all metrics
SELECT
  mcs.navigational_status as most_common_status,
  mcs.total_count as most_common_status_count,
  (mcs.total_count / tr.all_records) * 100 as most_common_status_percentage,
  tr.all_records as total_records,
  dwd.day_count as days_with_data
FROM
  most_common_status mcs,
  total_records tr,
  days_with_data dwd
WHERE
  mcs.status_rank = 1
