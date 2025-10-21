-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_xxx, stg_xxx;

-- =======================================
-- Load ft_name1 (seed, FK-safe)
-- =======================================

-- 1) Truncate target
TRUNCATE TABLE ft_name1 RESTART IDENTITY CASCADE;

INSERT INTO dim_sensortype (
    tb_sensortype_id, typename, manufacturer, technology, etl_load_timestamp)

SELECT 
    st.id,
    st.typename,
    st.manufacturer,
    st.technology,
FROM tb_sensortype st
ORDER BY st.id;