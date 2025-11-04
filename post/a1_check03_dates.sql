SET search_path TO dwh_061, stg_061;

WITH coverage AS (
  SELECT 'SensorData' AS fact_name,
         MIN(day_id) AS min_date,
         MAX(day_id) AS max_date,
         COUNT(DISTINCT day_id) AS covered_days
  FROM ft_sensordata
  UNION ALL
  SELECT 'ServiceEvent',
         MIN(day_id),
         MAX(day_id),
         COUNT(DISTINCT day_id)
  FROM ft_service_event
)
SELECT
  fact_name, min_date, max_date, covered_days,
  CASE 
    WHEN min_date = 20230101 AND max_date = 20241231 THEN 'OK' ELSE 'fail'
  END AS status_check
FROM coverage;