SET search_path TO dwh2_061;

--- For 2024, show total Data Volume (KB) by Region × Quarter. Return Regions on rows and the
--- four quarters of 2024 on columns.

SELECT
dc.region_name AS region, 
t.quarter_num AS quarter,
SUM(f.data_volume_kb_sum) AS total_data_volume_kb
FROM dwh2_061.ft_param_city_month f
JOIN dwh2_061.dim_city dc ON f.city_key = dc.city_key
JOIN dwh2_061.dim_timemonth t ON f.month_key = t.month_key
WHERE t.year_num = 2024
GROUP BY dc.region_name, t.quarter_num
ORDER BY dc.region_name, t.quarter_num;