-- =======================================
-- Load ft_service_event
-- =======================================
SET search_path TO dwh_061, stg_061;

-- Step 1️⃣: Truncate target table
TRUNCATE TABLE ft_service_event RESTART IDENTITY CASCADE;

-- Step 2️⃣: Insert transformed data
INSERT INTO ft_service_event (
    day_id,
    sk_device,
    sk_servicetype,
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
    dt.sk_technician,
    se.servicecost AS service_cost,
    se.durationminutes AS service_duration_minutes,
    se.servicequality AS service_quality_score,
    CASE 
        WHEN dt.role_level < ds.min_required_level THEN TRUE 
        ELSE FALSE 
    END AS underqualified_flag
FROM tb_serviceevent se
    -- time mapping
    JOIN dim_timeday td 
        ON se.servicedat = td.date_value

    -- service type
    JOIN tb_servicetype st 
        ON se.servicetypeid = st.id

    -- technician (directly, no SCD2)
    JOIN tb_employee e 
        ON se.employeeid = e.id

    -- device
    JOIN tb_sensordevice dev 
        ON se.sensordevid = dev.id

    -- dimension surrogate key lookups
    JOIN dwh_061.dim_device dd 
        ON dev.id = dd.tb_sensordevice_id
    JOIN dwh_061.dim_servicetype ds 
        ON st.id = ds.tb_servicetype_id
    JOIN dwh_061.dim_technician dt 
        ON e.id = dt.tb_employee_id

ORDER BY td.id, dd.sk_device;