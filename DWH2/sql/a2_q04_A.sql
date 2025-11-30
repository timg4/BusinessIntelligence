SET search_path TO dwh2_061;

--- For 2024, show total Data Volume (KB) by Region × Quarter. Return Regions on rows and the
--- four quarters of 2024 on columns.

SELECT
    dc.region_name AS region,
    SUM(CASE WHEN t.quarter_num = 1 THEN f.data_volume_kb_sum END) AS Q1_2024,
    SUM(CASE WHEN t.quarter_num = 2 THEN f.data_volume_kb_sum END) AS Q2_2024,
    SUM(CASE WHEN t.quarter_num = 3 THEN f.data_volume_kb_sum END) AS Q3_2024,
    SUM(CASE WHEN t.quarter_num = 4 THEN f.data_volume_kb_sum END) AS Q4_2024
FROM dwh2_061.ft_param_city_month f
JOIN dwh2_061.dim_city dc ON f.city_key = dc.city_key
JOIN dwh2_061.dim_timemonth t ON f.month_key = t.month_key
WHERE t.year_num = 2024
GROUP BY dc.region_name
ORDER BY dc.region_name;