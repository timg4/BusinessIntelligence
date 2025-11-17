SET search_path TO dwh_061, stg_061;

WITH joined AS (
  SELECT COUNT(*) AS joined_rows
  FROM ft_SensorData s
  JOIN dim_parameter dp      ON dp.sk_parameter = s.sk_parameter
  JOIN stg_061.tb_parameter_source ps ON ps.parameter_id = dp.tb_param_id
  JOIN tb_emissionsource de  ON de.id = ps.id
)
SELECT
  joined_rows,
  CASE WHEN joined_rows > 0 THEN 'OK' ELSE 'fail' END AS status_check
FROM joined;