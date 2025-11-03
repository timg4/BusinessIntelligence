-- =======================================
-- Load ft_service_event
-- =======================================
SET search_path TO dwh_061, stg_061;

-- Step 1️⃣: Truncate the target fact table (safe for re-runs)
TRUNCATE TABLE ft_service_event RESTART IDENTITY CASCADE;

-- Step 2️⃣: Insert transformed data
INSERT INTO ft_service_event (
    day_id,
    sk_device,
    sk_servicetype,
    sk_technician_role,
    sk_technician,
    service_cost,
    service_duration_minutes,
    service_quality_score,
    underqualified_flag
)
SELECT
    td.id AS day_id,
    dd.sk_device,
    ds.sk_servicetype,
    dtr.sk_technician_role,
    dt.sk_technician,
    se.cost AS service_cost,
    se.duration_minutes AS service_duration_minutes,
    se.quality_score AS service_quality_score,
    CASE 
        WHEN tr.rolelevel < st.min_required_level THEN TRUE 
        ELSE FALSE 
    END AS underqualified_flag
FROM tb_service_event se
    -- join calendar
    JOIN tb_timeday td 
        ON se.service_date = td.date_value

    -- join service type
    JOIN tb_servicetype st 
        ON se.servicetype_id = st.id

    -- join technician role (for SCD2 validity)
    JOIN tb_technician_role tr 
        ON se.technician_id = tr.technician_id
        AND se.service_date BETWEEN tr.effective_from AND tr.effective_to

    -- join device info
    JOIN tb_sensordevice dev 
        ON se.device_id = dev.id

    -- join dimension surrogate keys in DWH
    JOIN dwh_061.dim_device dd 
        ON dev.id = dd.tb_sensordevice_id
    JOIN dwh_061.dim_servicetype ds 
        ON st.id = ds.tb_servicetype_id
    JOIN dwh_061.dim_technician_role_scd2 dtr 
        ON tr.badgenumber = dtr.badgenumber
        AND tr.effective_from = dtr.effective_from
    JOIN dwh_061.dim_technician dt 
        ON se.technician_id = dt.tb_technician_id

ORDER BY td.id, dd.sk_device;

-- Optional sanity output
-- SELECT COUNT(*) AS rows_loaded FROM ft_service_event;
