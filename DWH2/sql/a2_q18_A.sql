-- Q18: For 2023, show Reading Events by Quarter for Vienna, Berlin, Moscow, and London (all
-- parameters). Return the four cities on rows and the four quarters of 2023 (Q1–Q4) on columns.
SET search_path TO dwh2_061;

SELECT
    dc.city_name,
    SUM(f.reading_events_count) FILTER (WHERE dt.quarter_num = 1) AS q1_events,
    SUM(f.reading_events_count) FILTER (WHERE dt.quarter_num = 2) AS q2_events,
    SUM(f.reading_events_count) FILTER (WHERE dt.quarter_num = 3) AS q3_events,
    SUM(f.reading_events_count) FILTER (WHERE dt.quarter_num = 4) AS q4_events
FROM dwh2_061.ft_param_city_month f
JOIN dwh2_061.dim_city dc ON f.city_key = dc.city_key
JOIN dwh2_061.dim_timemonth dt ON f.month_key = dt.month_key
WHERE dt.year_num = 2023 AND dc.city_name IN ('Vienna', 'Berlin', 'Moscow', 'London')
GROUP BY dc.city_name
ORDER BY dc.city_name;