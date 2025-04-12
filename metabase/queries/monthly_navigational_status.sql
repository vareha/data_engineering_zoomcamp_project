-- Monthly Navigational Status Trends Query
-- This query retrieves data for the time series chart showing navigational status trends by month

SELECT
  month_start_date,
  navigational_status,
  SUM(percentage) as status_percentage
FROM
  `de-zoomcamp-project-455806.marts.monthly_navigational_status`
WHERE
  month_start_date BETWEEN {{start_date}} AND {{end_date}}
  {% if navigational_status %}
  AND navigational_status = {{navigational_status}}
  {% endif %}
GROUP BY
  month_start_date,
  navigational_status
ORDER BY
  month_start_date ASC,
  navigational_status ASC
