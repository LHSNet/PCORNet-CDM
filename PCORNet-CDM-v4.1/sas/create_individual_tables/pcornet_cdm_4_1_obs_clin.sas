/*--------------------------------------------------------------------------------------\

CDM 4.1 OBS_CLIN TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.OBS_CLIN (compress=yes encrypt=aes encryptkey=&aeskey) as
SELECT 
    OBSCLINID ,
    PATID ,
    ENCOUNTERID ,
    OBSCLIN_PROVIDERID ,
    INPUT( PUT( OBSCLIN_DATE , e8601da.) , e8601da.) AS OBSCLIN_DATE format date9. ,
    INPUT( OBSCLIN_TIME , time.) AS OBSCLIN_TIME format hhmm. ,   
    OBSCLIN_TYPE ,
    OBSCLIN_CODE ,
    OBSCLIN_RESULT_QUAL ,
    OBSCLIN_RESULT_TEXT ,
    OBSCLIN_RESULT_SNOMED ,
    OBSCLIN_RESULT_NUM ,
    OBSCLIN_RESULT_MODIFIER ,
    OBSCLIN_RESULT_UNIT ,
    RAW_OBSCLIN_NAME ,
    RAW_OBSCLIN_CODE ,
    RAW_OBSCLIN_TYPE ,
    RAW_OBSCLIN_RESULT ,
    RAW_OBSCLIN_MODIFIER ,
    RAW_OBSCLIN_UNIT
FROM cdm_in.OBS_CLIN
;
