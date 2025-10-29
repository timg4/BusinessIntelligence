-- Make A1 dwh_xxx, stg_xxx schemas default for this session
SET search_path TO dwh_061, stg_061;

WITH invalids AS (
  SELECT
    SUM(CASE WHEN measure_value < 0 THEN 1 ELSE 0 END) AS negative_values,
    SUM(CASE WHEN data_quality NOT BETWEEN 1 AND 5 THEN 1 ELSE 0 END) AS invalid_quality,
    SUM(CASE WHEN alert_flag NOT IN (1,0) THEN 1 ELSE 0 END) AS invalid_flags
  FROM ft_SensorData
)
SELECT
  negative_values, invalid_quality, invalid_flags,
  CASE WHEN negative_values=0 AND invalid_quality=0 AND invalid_flags=0
       THEN 'OK' ELSE 'fail' END AS status_check
FROM invalids;


