-- =======================================
-- Load dim_servicetype
-- =======================================
SET search_path TO dwh_061, stg_061;

-- Step 1: Truncate target table
TRUNCATE TABLE dim_servicetype RESTART IDENTITY CASCADE;

-- Step 2: Insert data
INSERT INTO dim_servicetype (
    tb_servicetype_id,
    servicegroup,
    category,
    typename,
    min_required_level,
    qualification_level_name
)
SELECT 
    st.id AS tb_servicetype_id,
    st.servicegroup,
    st.category,
    st.typename,
    st.min_required_level,
    CASE st.min_required_level
        WHEN 1 THEN 'Entry'
        WHEN 2 THEN 'Junior'
        WHEN 3 THEN 'Senior'
        WHEN 4 THEN 'Lead'
        ELSE 'Unknown'
    END AS qualification_level_name
FROM tb_servicetype st
ORDER BY st.id;
