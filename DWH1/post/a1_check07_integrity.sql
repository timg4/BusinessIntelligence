SET search_path TO dwh_061, stg_061;

WITH joined AS (
  SELECT COUNT(*) AS joined_rows
  FROM ft_service_event f
  JOIN dim_device      dd ON dd.sk_device      = f.sk_device
  JOIN dim_servicetype ds ON ds.sk_servicetype = f.sk_servicetype
  JOIN dim_technician  dt ON dt.sk_technician  = f.sk_technician
  JOIN dim_timeday     td ON td.id             = f.day_id
)
SELECT *,
  CASE 
      WHEN joined_rows = (SELECT COUNT(*) FROM ft_service_event)
      THEN 'OK' 
      ELSE 'fail' 
  END AS status_check
FROM joined;
