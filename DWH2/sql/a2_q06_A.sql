-- Q6: For 2024, list the Top 10 Cities by total Missing Days (all parameters).
-- Return the 10 cities with the highest totals on rows (highest → lowest)
-- and one column with the 2024 total Missing Days.

SET search_path TO dwh2_061;

SELECT
    dc.city_name,
    SUM(f.missing_days) AS total_missing_days_2024
FROM dwh2_061.ft_param_city_month f
JOIN dwh2_061.dim_city dc
    ON f.city_key = dc.city_key
JOIN dwh2_061.dim_timemonth dt
    ON f.month_key = dt.month_key
WHERE dt.year_num = 2024
GROUP BY dc.city_name
ORDER BY total_missing_days_2024 DESC
LIMIT 10;
