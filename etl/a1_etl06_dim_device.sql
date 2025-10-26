-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_061, stg_061;

-- =======================================
-- Load ft_name1 (seed, FK-safe)
-- =======================================

-- 1) Truncate target
TRUNCATE TABLE dim_device RESTART IDENTITY CASCADE;

INSERT INTO dim_device(
    tb_sensordevice_id,
    locationname,
    locationtype,
    altitude,
    cityname,
    countryname,
    population_city,
    population_country,
    latitude,
    longitude
)

SELECT
    sd.id AS tb_sensordevice_id,
    sd.locationname,
    sd.locationtype,
    sd.altitude,
    c.cityname,
    co.countryname,
    c.population,
    co.population,
    c.latitude,
    c.longitude
FROM tb_sensordevice sd
JOIN tb_city c ON sd.cityid = c.id
JOIN tb_country co ON c.countryid = co.id
ORDER BY sd.id;