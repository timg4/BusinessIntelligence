-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_xxx, stg_xxx;

-- =======================================
-- Load ft_name1 (seed, FK-safe)
-- =======================================

-- 1) Truncate target
TRUNCATE TABLE ft_name1 RESTART IDENTITY CASCADE;

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
    sd.id AS tb_sensordevice_id
    sd.locationname,
    sd.locationtype,
    sd.altitude,
    c.cityname,
    co.countryname,
    c.population_city,
    co.population_country,
    c.latitude,
    c.longitude
FROM tb_sensordevice 
JOIN tb_city c ON sd.city_id = c.id
JOIN tb_country co ON c.country_id = co.id
ORDER BY sd.id;