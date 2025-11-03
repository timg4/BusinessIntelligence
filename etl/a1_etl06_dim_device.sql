-- =======================================
-- Load dim_device
-- =======================================
SET search_path TO dwh_061, stg_061;

-- Step 1: Truncate target
TRUNCATE TABLE dim_device RESTART IDENTITY CASCADE;

-- Step 2: Insert data
INSERT INTO dim_device (
    tb_sensordevice_id,
    locationname,
    locationtype,
    altitude,
    cityname,
    countryname,
    population_city,
    population_country,
    latitude,
    longitude,
    manufacturer
)
SELECT
    sd.id AS tb_sensordevice_id,
    sd.locationname,
    sd.locationtype,
    sd.altitude,
    c.cityname,
    co.countryname,
    c.population AS population_city,
    co.population AS population_country,
    c.latitude,
    c.longitude,
    st.manufacturer
FROM tb_sensordevice sd
JOIN tb_city c ON sd.cityid = c.id
JOIN tb_country co ON c.countryid = co.id
LEFT JOIN tb_sensortype st ON sd.sensortypeid = st.id
ORDER BY sd.id;
