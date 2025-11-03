SET search_path TO dwh_061;

WITH bad AS (
  SELECT COUNT(*) AS null_rows
  FROM ft_service_event
  WHERE day_id IS NULL
     OR sk_device IS NULL
     OR sk_servicetype IS NULL
     OR sk_technician IS NULL
     OR service_cost IS NULL
     OR service_duration_minutes IS NULL
     OR service_quality_score IS NULL
)
SELECT
  null_rows,
  CASE WHEN null_rows = 0 THEN 'OK' ELSE 'fail' END AS status_check;
