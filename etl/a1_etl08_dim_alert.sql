-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_xxx, stg_xxx;

-- =======================================
-- Load ft_name1 (seed, FK-safe)
-- =======================================

-- 1) Truncate target
TRUNCATE TABLE ft_name1 RESTART IDENTITY CASCADE;

INSERT INTO dim_alert (
    tb_alert_id,
    alertname,
    colour,
    details,
    severity_level
)
SELECT
    a.id              AS tb_alert_id,
    a.alertname,
    a.colour,
    a.details,
    CASE
        WHEN a.alertname = 'Yellow'  THEN 1
        WHEN a.alertname = 'Orange'  THEN 2
        WHEN a.alertname = 'Red'     THEN 3
        WHEN a.alertname = 'Crimson' THEN 4
        ELSE NULL
    END AS severity_level
FROM tb_alert a
ORDER BY a.id;

-- Step 3: Update optimizer stats
ANALYZE dim_alert;