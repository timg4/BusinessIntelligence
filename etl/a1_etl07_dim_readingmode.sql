-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_xxx, stg_xxx;

-- =======================================
-- Load ft_name1 (seed, FK-safe)
-- =======================================

-- 1) Truncate target
TRUNCATE TABLE ft_name1 RESTART IDENTITY CASCADE;


WITH mode_history AS (
    SELECT
        rm.id AS tb_readingmode_id,
        rm.modename,
        rm.latency,
        rm.details,
        rm.validfrom AS valid_from,
        COALESCE(rm.validto, DATE '9999-12-31') AS valid_to,
        (rm.validto IS NULL) AS is_current
    FROM tb_readingmode rm
)

INSERT INTO dim_readingmode (
    tb_readingmode_id,
    modename,
    latency,
    details,
    valid_from,
    valid_to,
    is_current
)
SELECT
    tb_readingmode_id,
    modename,
    latency,
    details,
    valid_from,
    valid_to,
    is_current
FROM mode_history
ORDER BY tb_readingmode_id, valid_from;


