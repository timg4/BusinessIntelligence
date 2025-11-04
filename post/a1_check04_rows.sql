SET search_path TO dwh_061, stg_061;

WITH counts AS (
  SELECT 'SensorData' AS fact_name,
         (SELECT COUNT(*) FROM ft_sensordata) AS dwh_count,
         (SELECT COUNT(*) FROM tb_readingevent) AS stg_count
  UNION ALL
  SELECT 'ServiceEvent',
         (SELECT COUNT(*) FROM ft_service_event),
         (SELECT COUNT(*) FROM tb_serviceevent)
)
SELECT
  fact_name,
  dwh_count,
  stg_count,
  CASE WHEN dwh_count <= stg_count THEN 'OK' ELSE 'fail' END AS status_check
FROM counts;