SET search_path TO dwh_061, stg_061;

WITH dwh_st AS (
  SELECT '061' AS group_num,
         COUNT(*) AS dwh_count
  FROM ft_SensorData
), stg_st AS (
  SELECT '061' AS group_num,
         COUNT(*) AS stg_count
  FROM tb_readingevent
)

SELECT
dwh_count,
stg_count,
CASE    
    WHEN dwh_count <= stg_count THEN 'OK' 
    ELSE 'fail' 
END AS status_check
FROM dwh_st d
JOIN stg_st s ON d.group_num = s.group_num;