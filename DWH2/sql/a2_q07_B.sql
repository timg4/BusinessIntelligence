-- Q7: For parameter PM10, show Avg Recorded Value and P95 Recorded Value by Country for 2023.
-- Return Countries on rows and two columns—Avg Recorded Value and P95 Recorded Value—for 2023.

SET search_path TO dwh2_061;

SELECT
    dc.country_name,
    AVG(f.recordedvalue_avg)  AS avg_recorded_value_2023,
    AVG(f.recordedvalue_p95)  AS p95_recorded_value_2023
FROM dwh2_061.ft_param_city_month f
JOIN dwh2_061.dim_city dc
    ON f.city_key = dc.city_key
JOIN dwh2_061.dim_param dp
    ON f.param_key = dp.param_key
JOIN dwh2_061.dim_timemonth dt
    ON f.month_key = dt.month_key
WHERE dp.param_name = 'PM10'
  AND dt.year_num = 2023
GROUP BY dc.country_name
ORDER BY dc.country_name;
