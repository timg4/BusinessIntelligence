-- Q14:  For 2024, list the Top 10 City × Param pairs by Avg Data Quality. Return the 10 City–Param
-- pairs with the highest values on rows (highest -> lowest) and one column with Avg Data Quality
-- for 2024
SET search_path TO dwh2_061;

SELECT
    dc.city_name,
    dp.param_name,
    AVG(f.data_quality_avg) AS avg_data_quality
FROM dwh2_061.ft_param_city_month f
JOIN dwh2_061.dim_city dc
    ON f.city_key = dc.city_key
JOIN dwh2_061.dim_param dp
    ON f.param_key = dp.param_key
JOIN dwh2_061.dim_timemonth dt
    ON f.month_key = dt.month_key
WHERE dt.year_num = 2024
GROUP BY
    dc.city_name,
    dp.param_name
ORDER BY avg_data_quality DESC
LIMIT 10;