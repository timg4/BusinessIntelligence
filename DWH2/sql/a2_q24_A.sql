-- Business question Q24 For parameter CO2, show P95 Recorded Value by Country for 2024. Return Countries on rows
-- and one column with P95 Recorded Value for the year 2024.

SET search_path TO dwh2_061;

SELECT dc.country_name,
AVG(f.recordedvalue_p95) AS p95_recorded_value
FROM dwh2_061.ft_param_city_month f
JOIN dwh2_061.dim_city dc ON f.city_key = dc.city_key
JOIN dwh2_061.dim_param dp ON f.param_key = dp.param_key
JOIN dwh2_061.dim_timemonth dt ON f.month_key = dt.month_key
WHERE dp.param_name = 'CO2' AND dt.year_num = 2024
GROUP BY dc.country_name
ORDER BY p95_recorded_value DESC;