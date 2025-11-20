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

WITH sensorbasis AS(
    SELECT 
    re.readat,
    re.recordedvalue,
    re.datavolumekb,
    re.dataquality, 
    re.paramid,
    re.sensordevid,
    sd.cityid,
    sd.id as sensordeviceid
    FROM tb_readingevent re 
    JOIN tb_sensordevice sd ON sd.id = re.sensordevid

),

graindata AS (
    SELECT
        sb.*,
        dc.city_key,
        dp.param_key,
        dt.month_key,
        dt.mfirst_day,
        dt.mlast_day
    FROM sensorbasis sb
    JOIN tb_city c ON c.id = sb.cityid
    JOIN dim_city dc ON dc.city_name = c.cityname
    JOIN tb_param p ON p.id = sb.paramid
    JOIN dim_param dp ON dp.param_name = p.paramname
    JOIN dim_timemonth dt 
        ON sb.readat BETWEEN dt.mfirst_day AND dt.mlast_day
),

alertthresholds AS (
    SELECT 
        pa.paramid,
        MAX(CASE WHEN a.colour='Yellow'  THEN pa.threshold END) AS th_yellow,
        MAX(CASE WHEN a.colour='Orange'  THEN pa.threshold END) AS th_orange,
        MAX(CASE WHEN a.colour='Red'     THEN pa.threshold END) AS th_red,
        MAX(CASE WHEN a.colour='Crimson' THEN pa.threshold END) AS th_crimson
    FROM tb_paramalert pa
    JOIN tb_alert a ON a.id = pa.alertid
    GROUP BY pa.paramid
),

alertranks AS (
    SELECT
        gr.month_key,
        gr.city_key,
        gr.param_key,
        gr.readat,
        gr.recordedvalue,
        gr.datavolumekb,
        gr.dataquality,
        gr.sensordevid,
        CASE
            WHEN t.th_crimson IS NOT NULL AND gr.recordedvalue >= t.th_crimson THEN 4
            WHEN t.th_red     IS NOT NULL AND gr.recordedvalue >= t.th_red     THEN 3
            WHEN t.th_orange  IS NOT NULL AND gr.recordedvalue >= t.th_orange  THEN 2
            WHEN t.th_yellow  IS NOT NULL AND gr.recordedvalue >= t.th_yellow  THEN 1
            ELSE 0
        END AS alert_rank
    FROM graindata gr
    LEFT JOIN alertthresholds t ON t.paramid = gr.paramid
),


dailyaggr AS (
    SELECT
        month_key,
        city_key,
        param_key,
        readat,
        MAX(alert_rank) AS daily_alert_rank
    FROM alertranks
    GROUP BY month_key, city_key, param_key, readat
),

monthlyaggr AS (
    SELECT
        ar.month_key,
        ar.city_key,
        ar.param_key,

        COUNT(DISTINCT (ar.sensordevid, ar.readat)) AS reading_events_count,
        COUNT(DISTINCT ar.sensordevid) AS devices_reporting_count,

        AVG(ar.recordedvalue) AS recordedvalue_avg,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY ar.recordedvalue) AS recordedvalue_p95,

        SUM(ar.datavolumekb) AS data_volume_kb_sum,
        AVG(ar.dataquality) AS data_quality_avg
    FROM alertranks ar
    GROUP BY ar.month_key, ar.city_key, ar.param_key
),

exceeded AS (
SELECT
        month_key,
        city_key,
        param_key,
        COUNT(*) FILTER (WHERE daily_alert_rank > 0) AS exceed_days_any,
        MAX(daily_alert_rank) AS month_peak_rank
    FROM dailyaggr
    GROUP BY month_key, city_key, param_key
),

days_calc AS (
    SELECT
        dtm.month_key,
        (mlast_day - mfirst_day + 1) AS days_in_month
    FROM dim_timemonth dtm
    GROUP BY dtm.month_key
),

days_with_readings AS (
    SELECT
        month_key,
        city_key,
        param_key,
        COUNT(DISTINCT readat) AS days_with_readings
    FROM dailyaggr
    GROUP BY month_key, city_key, param_key
),

final_cte AS (
    SELECT
        ma.month_key,
        ma.city_key,
        ma.param_key,
        ma.reading_events_count,
        ma.devices_reporting_count,
        ma.recordedvalue_avg,
        ma.recordedvalue_p95,
        ma.data_volume_kb_sum,
        ma.data_quality_avg,
        ex.exceed_days_any,
        ex.month_peak_rank,
        dr.days_with_readings,
        dc.days_in_month,

        (dc.days_in_month - dr.days_with_readings) AS missing_days,
        CASE ex.month_peak_rank
            WHEN 4 THEN 1004
            WHEN 3 THEN 1003
            WHEN 2 THEN 1002
            WHEN 1 THEN 1001
            ELSE 1000
        END AS alertpeak_key

    FROM monthlyaggr ma
    LEFT JOIN exceeded ex 
        ON ex.month_key = ma.month_key 
       AND ex.city_key = ma.city_key 
       AND ex.param_key = ma.param_key
    LEFT JOIN days_with_readings dr 
        ON dr.month_key = ma.month_key 
       AND dr.city_key = ma.city_key 
       AND dr.param_key = ma.param_key
    JOIN days_calc dc 
        ON dc.month_key = ma.month_key
)

INSERT INTO ft_param_city_month (
    ft_pcm_key,
    month_key, city_key, param_key, alertpeak_key,
    reading_events_count,
    devices_reporting_count,
    recordedvalue_avg,
    recordedvalue_p95,
    exceed_days_any,
    data_volume_kb_sum,
    data_quality_avg,
    missing_days
)

SELECT
    ROW_NUMBER() OVER () AS ft_pcm_key,
    month_key, city_key, param_key, alertpeak_key,
    reading_events_count,
    devices_reporting_count,
    recordedvalue_avg,
    recordedvalue_p95,
    exceed_days_any,
    data_volume_kb_sum,
    data_quality_avg,
    missing_days
FROM final_cte
ORDER BY month_key, city_key, param_key;
