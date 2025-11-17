SET search_path TO dwh_061, stg_061;

-- check invalid values in the sensor ft
WITH sensor_invalids AS (
  SELECT
    SUM(CASE WHEN measure_value < 0 THEN 1 ELSE 0 END) AS negative_values,
    SUM(CASE WHEN data_quality NOT BETWEEN 1 AND 5 THEN 1 ELSE 0 END) AS invalid_quality,
    SUM(CASE WHEN alert_flag NOT IN (1,0) THEN 1 ELSE 0 END) AS invalid_flags
  FROM ft_sensordata
),
-- check invalid values in the service ft
service_invalids AS (
  SELECT
    SUM(CASE WHEN service_cost < 0 THEN 1 ELSE 0 END) AS negative_costs,
    SUM(CASE WHEN service_duration_minutes < 0 THEN 1 ELSE 0 END) AS negative_durations,
    SUM(CASE WHEN service_quality_score NOT BETWEEN 1 AND 5 THEN 1 ELSE 0 END) AS invalid_quality
  FROM ft_service_event
)
SELECT
  s.negative_values,
  s.invalid_quality,
  s.invalid_flags,
  se.negative_costs,
  se.negative_durations,
  se.invalid_quality AS service_invalid_quality,
  CASE 
    WHEN COALESCE(s.negative_values,0)=0 
     AND COALESCE(s.invalid_quality,0)=0 
     AND COALESCE(s.invalid_flags,0)=0
     AND COALESCE(se.negative_costs,0)=0 
     AND COALESCE(se.negative_durations,0)=0
     AND COALESCE(se.invalid_quality,0)=0
    THEN 'OK' ELSE 'fail' 
  END AS status_check
FROM sensor_invalids s
CROSS JOIN service_invalids se;
