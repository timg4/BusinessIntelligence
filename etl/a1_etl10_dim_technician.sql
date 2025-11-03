-- =======================================
-- Load dim_technician
-- =======================================
SET search_path TO dwh_061, stg_061;

-- Step 1: Truncate
TRUNCATE TABLE dim_technician RESTART IDENTITY CASCADE;

-- Step 2: Insert data
INSERT INTO dim_technician (
    tb_technician_id,
    technician_name,
    department_name,
    region_name,
    qualification_level,
    hire_date
)
SELECT 
    t.id AS tb_technician_id,
    t.fullname AS technician_name,
    d.name AS department_name,
    r.regionname AS region_name,
    t.qualification_level,
    t.hire_date
FROM tb_technician t
LEFT JOIN tb_department d ON t.department_id = d.id
LEFT JOIN tb_region r ON d.region_id = r.id
ORDER BY t.id;
