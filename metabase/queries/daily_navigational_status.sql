-- Daily Navigational Status Distribution Query
-- This query retrieves data for the pie chart showing navigational status distribution for a specific day

SELECT
  navigational_status,
  SUM(percentage) as status_percentage
FROM
  `de-zoomcamp-project-455806.marts.daily_navigational_status`
WHERE
  date BETWEEN {{start_date}} AND {{end_date}}
GROUP BY
  navigational_status
ORDER BY
  status_percentage DESC
