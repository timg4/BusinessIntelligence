-- Q5: For 2023 and 2024, show total Data Volume (KB) by Param Category × Year.
-- Return Param Categories on rows and the two years (2023, 2024) on columns.

SET search_path TO dwh2_061;

SELECT
    dp.category,
    SUM(f.data_volume_kb_sum) FILTER (WHERE dt.year_num = 2023) AS data_volume_2023_kb,
    SUM(f.data_volume_kb_sum) FILTER (WHERE dt.year_num = 2024) AS data_volume_2024_kb
FROM dwh2_061.ft_param_city_month f
JOIN dwh2_061.dim_param dp
    ON f.param_key = dp.param_key
JOIN dwh2_061.dim_timemonth dt
    ON f.month_key = dt.month_key
WHERE dt.year_num IN (2023, 2024)
GROUP BY dp.category
ORDER BY dp.category;
