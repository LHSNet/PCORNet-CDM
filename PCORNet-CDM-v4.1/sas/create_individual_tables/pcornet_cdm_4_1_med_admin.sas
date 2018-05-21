/*--------------------------------------------------------------------------------------\

CDM 4.1 MED_ADMIN TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.MED_ADMIN (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT 
    MEDADMINID ,
    PATID ,
    ENCOUNTERID ,
    PRESCRIBINGID ,
    MEDADMIN_PROVIDERID ,
    INPUT( PUT( MEDADMIN_START_DATE , e8601da.), e8601da.) AS MEDADMIN_START_DATE format date9. ,
	INPUT( MEDADMIN_START_TIME , time.) AS MEDADMIN_START_TIME format hhmm.,
    INPUT( PUT( MEDADMIN_STOP_DATE , e8601da.), e8601da.) AS MEDADMIN_STOP_DATE format date9.,
    INPUT( MEDADMIN_STOP_TIME , time.) AS MEDADMIN_STOP_TIME format hhmm.,
    MEDADMIN_TYPE ,
    MEDADMIN_CODE ,
    MEDADMIN_DOSE_ADMIN ,
    MEDADMIN_DOSE_ADMIN_UNIT ,
    MEDADMIN_ROUTE ,
    MEDADMIN_SOURCE ,
    RAW_MEDADMIN_MED_NAME ,
    RAW_MEDADMIN_CODE ,
    RAW_MEDADMIN_DOSE_ADMIN ,
    RAW_MEDADMIN_DOSE_ADMIN_UNIT ,
    RAW_MEDADMIN_ROUTE
FROM cdm_in.MED_ADMIN
;


