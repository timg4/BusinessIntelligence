-- please remember to give a meaningful name to both Table X (instead of tb_x) and TableY (instead of tb_y)

-- Make the A1's stg_xxx schema the default for this session
SET search_path TO stg_061;

-- -------------------------------
-- 2) DROP TABLE before attempting to create OLTP snapshot tables
-- -------------------------------
DROP TABLE IF EXISTS tb_y;
DROP TABLE IF EXISTS tb_x;

-- give a meaningful name and create Table X

-- we add a emissionsource table here that shows us where the emissions come from
CREATE TABLE tb_emissionsource (
    id INT NOT NULL PRIMARY KEY,
    sourcetype VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

-- give a meaningful name and create Table Y
-- table y is tb_parameter_source - links parameter to their emissionsource
CREATE TABLE tb_parameter_source (
    id INT NOT NULL PRIMARY KEY
    , parameter_id INT NOT NULL
    , emissionsource_id INT NOT NULL
    , relevance INT CHECK (relevance BETWEEN 1 AND 5)
    , CONSTRAINT fk_param_source_parameter FOREIGN KEY (parameter_id) REFERENCES tb_param(id)
    , CONSTRAINT fk_param_source_emissionsource FOREIGN KEY (emissionsource_id) REFERENCES tb_emissionsource(id)
);


