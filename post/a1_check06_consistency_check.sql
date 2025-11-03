SET search_path TO dwh_061;

WITH check_flag AS (
  SELECT COUNT(*) AS mismatch
  FROM ft_service_event f
  JOIN dim_technician  t  ON f.sk_technician  = t.sk_technician
  JOIN dim_servicetype s  ON f.sk_servicetype = s.sk_servicetype
  WHERE (t.role_level < s.min_required_level  AND underqualified_flag = FALSE)
     OR (t.role_level >= s.min_required_level AND underqualified_flag = TRUE)
)
SELECT
  mismatch,
  CASE WHEN mismatch = 0 THEN 'OK' ELSE 'fail' END AS status_check;
