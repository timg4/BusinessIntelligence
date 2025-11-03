SET search_path TO dwh_061, stg_061;

TRUNCATE TABLE dim_emissionsource RESTART IDENTITY CASCADE;

INSERT INTO dim_emissionsource (
    tb_emissionsource_id,
    sourcetype,
    description
)
SELECT
    es.id as tb_emissionsource_id, 
    es.sourcetype,
    es.description
FROM tb_emissionsource es
ORDER BY es.id;