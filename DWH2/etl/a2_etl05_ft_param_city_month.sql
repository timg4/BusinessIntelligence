-- Assignment 2 ETL: ft_param_city_month
-- GRAIN: month_key × city_key × param_key

-- EXAMPLE SHAPE (sketch only):
-- TRUNCATE TABLE ft_param_city_month;
-- WITH cte1 AS (...),
--      cte2 AS (...),
--      cte3 AS (...),
--      ... AS (...),
--      final_cte AS (...)
-- INSERT INTO ft_param_city_month (...columns...)
-- SELECT ... FROM final_cte;

-- Make A2 dwh2_xxx, stg2_xxx schemas the default for this session
SET search_path TO dwh2_061, stg2_061;

-- =======================================
-- Load ft_param_city_month
-- =======================================

-- Step 1: Truncate target table - ft_param_city_month
TRUNCATE TABLE ft_param_city_month RESTART IDENTITY CASCADE;

-- ==========================================================
-- Assignment 2 — ETL for ft_param_city_month (REWRITTEN)
-- Grain: month_key × city_key × param_key
-- ==========================================================

SET search_path TO dwh2_061, stg2_061;

-- Clear fact table
TRUNCATE TABLE ft_param_city_month RESTART IDENTITY CASCADE;

WITH events AS (
    SELECT r.readat,
           r.recordedvalue,
           r.datavolumekb,
           r.dataquality,
           r.paramid,
           r.sensordevid,
           sd.cityid
    FROM tb_readingevent r
    JOIN tb_sensordevice sd ON sd.id = r.sensordevid
),

grain AS (
    SELECT e.*,
           dc.city_key,
           dp.param_key,
           tm.month_key,
           tm.mfirst_day,
           tm.mlast_day
    FROM events e
    JOIN tb_city c    ON c.id = e.cityid
    JOIN dim_city dc  ON dc.city_name = c.cityname
    JOIN tb_param p   ON p.id = e.paramid
    JOIN dim_param dp ON dp.param_name = p.paramname
    JOIN dim_timemonth tm
         ON e.readat >= tm.mfirst_day AND e.readat <= tm.mlast_day
),

alarmlvl AS (
    SELECT pa.paramid,
           MAX(CASE WHEN a.colour='Yellow'  THEN pa.threshold END) AS y,
           MAX(CASE WHEN a.colour='Orange'  THEN pa.threshold END) AS o,
           MAX(CASE WHEN a.colour='Red'     THEN pa.threshold END) AS r,
           MAX(CASE WHEN a.colour='Crimson' THEN pa.threshold END) AS c
    FROM tb_paramalert pa
    JOIN tb_alert a ON a.id = pa.alertid
    GROUP BY pa.paramid
),

alertclr AS (
    SELECT g.*,
           CASE
               WHEN g.recordedvalue >= al.c THEN 4
               WHEN g.recordedvalue >= al.r THEN 3
               WHEN g.recordedvalue >= al.o THEN 2
               WHEN g.recordedvalue >= al.y THEN 1
               ELSE 0
           END AS rk
    FROM grain g
    LEFT JOIN alarmlvl al ON g.paramid = al.paramid
),

maxalert AS (
    SELECT month_key, city_key, param_key, readat,
           MAX(rk) AS max_rk
    FROM alertclr
    GROUP BY month_key, city_key, param_key, readat
),

monthlycore AS (
    SELECT month_key, city_key, param_key,
           COUNT(*) AS cnt,
           COUNT(DISTINCT sensordevid) AS devs,
           AVG(recordedvalue) AS avg_val,
           PERCENTILE_CONT(0.95)
             WITHIN GROUP (ORDER BY recordedvalue) AS p95,
           SUM(datavolumekb) AS kb_sum,
           AVG(dataquality) AS q_avg
    FROM alertclr
    GROUP BY month_key, city_key, param_key
),

monthalert AS (
    SELECT month_key, city_key, param_key,
           COUNT(*) FILTER (WHERE max_rk > 0) AS ex_days,
           MAX(max_rk) AS peak
    FROM maxalert
    GROUP BY month_key, city_key, param_key
),

monthlen AS (
    SELECT month_key,
           (mlast_day - mfirst_day + 1) AS days
    FROM dim_timemonth
),

observations AS (
    SELECT month_key, city_key, param_key,
           COUNT(DISTINCT readat) AS d_obs
    FROM maxalert
    GROUP BY month_key, city_key, param_key
),

final AS (
    SELECT mc.month_key,
           mc.city_key,
           mc.param_key,
           mc.cnt,
           mc.devs,
           mc.avg_val,
           mc.p95,
           mc.kb_sum,
           mc.q_avg,
           COALESCE(ma.ex_days, 0) AS ex_days,
           CASE COALESCE(ma.peak,0)
               WHEN 4 THEN 1004
               WHEN 3 THEN 1003
               WHEN 2 THEN 1002
               WHEN 1 THEN 1001
               ELSE 1000
           END AS alertpeak_key,
           (ml.days - COALESCE(o.d_obs,0)) AS miss_days
    FROM  monthlycore mc
    LEFT JOIN monthalert ma  
           ON ma.month_key = mc.month_key
          AND ma.city_key  = mc.city_key
          AND ma.param_key = mc.param_key
    LEFT JOIN observations o
           ON o.month_key = mc.month_key
          AND o.city_key  = mc.city_key
          AND o.param_key = mc.param_key
    JOIN monthlen ml ON ml.month_key = mc.month_key
)

INSERT INTO ft_param_city_month (
    ft_pcm_key,
    month_key, city_key, param_key, alertpeak_key,
    reading_events_count, devices_reporting_count,
    recordedvalue_avg, recordedvalue_p95,
    exceed_days_any, data_volume_kb_sum,
    data_quality_avg, missing_days
)
SELECT
    ROW_NUMBER() OVER (),
    month_key, city_key, param_key, alertpeak_key,
    cnt, devs, avg_val, p95,
    ex_days, kb_sum,
    q_avg, miss_days
FROM final
ORDER BY month_key, city_key, param_key;
