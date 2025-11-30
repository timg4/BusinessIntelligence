-- Q25: For 2023 and 2024, show Exceed Days (any) by Purpose,
-- plus the change from 2023 to 2024.
-- Return Purposes on rows and three columns:
-- Exceed Days 2023, Exceed Days 2024, and Change 2024–2023.

SET search_path TO dwh2_061;

SELECT
    dp.purpose,
    SUM(f.exceed_days_any) FILTER (WHERE dt.year_num = 2023) AS exceed_days_2023,
    SUM(f.exceed_days_any) FILTER (WHERE dt.year_num = 2024) AS exceed_days_2024,
    COALESCE(SUM(f.exceed_days_any) FILTER (WHERE dt.year_num = 2024), 0)
    - COALESCE(SUM(f.exceed_days_any) FILTER (WHERE dt.year_num = 2023), 0)
      AS change_2024_minus_2023
FROM dwh2_061.ft_param_city_month f
JOIN dwh2_061.dim_param dp
    ON f.param_key = dp.param_key
JOIN dwh2_061.dim_timemonth dt
    ON f.month_key = dt.month_key
WHERE dt.year_num IN (2023, 2024)
GROUP BY dp.purpose
ORDER BY change_2024_minus_2023 DESC;
