-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_xxx, stg_xxx;

-- =======================================
-- Load dim_timeday
-- =======================================

-- Step 1: Truncate target table, the dim_timeday in this case
TRUNCATE TABLE dim_timeday RESTART IDENTITY CASCADE;

-- Step 2: Insert data into the dim_timeday
-- we see in the data that all our dates are between 01.01.2023 and 31.12.2024 
WITH series AS (
    SELECT
        generate_series(
            '2023-01-01'::DATE, 
            '2024-12-31'::DATE,
            INTERVAL '1 day'
        ) AS date
)

INSERT INTO dim_timeday (id, date_value, year, month, monthname, day, dayname, etl_load_timestamp)
SELECT
    EXTRACT(YEAR FROM date) * 10000 + 
    EXTRACT(MONTH FROM date) * 100 + 
    EXTRACT(DAY FROM date) AS id
    , date AS date_value
    , EXTRACT(YEAR FROM date)::INT AS year
    , EXTRACT(MONTH FROM date)::INT AS month
    , TO_CHAR(date, 'Month') AS monthname
    , EXTRACT(DAY FROM date)::INT AS day
    , TO_CHAR(date, 'Day') AS dayname
    , CURRENT_TIMESTAMP AS etl_load_timestamp
FROM series
ORDER BY date;

