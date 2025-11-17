-- =======================================
-- Load dim_technician
-- =======================================
SET search_path TO dwh_061, stg_061;

-- Step 1: Truncate
TRUNCATE TABLE dim_technician RESTART IDENTITY CASCADE;

-- Step 2: Insert data
INSERT INTO dim_technician (
    tb_employee_id,
    badgenumber,
    role_category,
    role_level,
    rolename
)
SELECT 
    e.id AS tb_employee_id,
    e.badgenumber,
    r.category AS role_category,
    r.rolelevel,
    r.rolename
FROM tb_employee e
JOIN tb_role r 
    ON e.roleid = r.id   
ORDER BY e.id;