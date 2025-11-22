-- Q3:For PM10 in 2024, show the total Exceed Days (any) by City. Return one row per city and a

SET search_path TO dwh2_061;

SELECT
    dc.city_name,
    SUM(f.exceed_days_any) AS total_exceed_days
FROM dwh2_061.ft_param_city_month f
JOIN dwh2_061.dim_city dc
    ON f.city_key = dc.city_key
JOIN dwh2_061.dim_param dp
    ON f.param_key = dp.param_key
JOIN dwh2_061.dim_timemonth dt
    ON f.month_key = dt.month_key
WHERE dp.param_name = 'PM10'
  AND dt.year_num = 2024
GROUP BY dc.city_name
ORDER BY total_exceed_days DESC;
