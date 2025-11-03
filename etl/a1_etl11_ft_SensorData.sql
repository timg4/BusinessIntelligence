SET search_path TO dwh_061, stg_061;

TRUNCATE TABLE ft_SensorData RESTART IDENTITY CASCADE;

INSERT INTO ft_SensorData (
    day_id,
    sk_parameter,
    sk_device,
    sk_sensortype,
    sk_readingmode,
    sk_alert,
    sk_emissionsource,
    measure_value,
    data_quality,
    alert_flag,
    alert_level,
    weather_tempavgday
)

SELECT
    td.id AS day_id,                             
    dp.sk_parameter,                              
    dd.sk_device,                                 
    ds.sk_sensortype,                             
    drm.sk_readingmode,                           
    da.sk_alert,
    des.sk_emissionsource,                                   
    re.recordedvalue,                             
    re.dataquality,                               
    CASE WHEN re.recordedvalue > pa.threshold THEN 1 ELSE 0 END AS alert_flag,
    a.id AS alert_level,                         
    w.tempdayavg                                  
FROM stg_061.tb_readingevent re
JOIN dim_parameter dp ON dp.tb_param_id = re.paramid
JOIN stg_061.tb_sensordevice sd ON sd.id = re.sensordevid
JOIN dim_device dd ON dd.tb_sensordevice_id = sd.id
JOIN dim_sensortype ds ON ds.tb_sensortype_id = sd.sensortypeid
JOIN dim_readingmode drm ON drm.tb_readingmode_id = re.readingmodeid
JOIN dim_timeday td  ON td.date_value = re.readat

-- we need to do that to only select the highest alarm otherwise we have way too many entries in the fact table
LEFT JOIN (
    SELECT DISTINCT ON (paramid)
           paramid, alertid, threshold
    FROM stg_061.tb_paramalert
    ORDER BY paramid, threshold DESC
) pa ON pa.paramid = re.paramid
LEFT JOIN stg_061.tb_alert a ON a.id = pa.alertid
LEFT JOIN dim_alert da ON da.tb_alert_id = a.id

-- the same goes for the emission source
LEFT JOIN (
    SELECT DISTINCT ON (parameter_id)
           parameter_id, emissionsource_id
    FROM stg_061.tb_parameter_source
    ORDER BY parameter_id, relevance DESC
) ps ON ps.parameter_id = re.paramid
LEFT JOIN dim_emissionsource des
       ON des.tb_emissionsource_id = ps.emissionsource_id

LEFT JOIN stg_061.tb_weather w ON w.cityid = sd.cityid AND w.observedat = re.readat;