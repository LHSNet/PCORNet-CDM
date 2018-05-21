/*--------------------------------------------------------------------------------------\

CDM 4.1 OBS_GEN TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.OBS_GEN (compress=yes encrypt=aes encryptkey=&aeskey) as
SELECT 
    OBSGENID ,
    PATID ,
    ENCOUNTERID ,
    OBSGEN_PROVIDERID ,
    INPUT( PUT( OBSGEN_DATE, e8601da.), e8601da.) AS OBSGEN_DATE format date9. ,
	INPUT( OBSGEN_TIME , time.) AS OBSGEN_TIME format hhmm. ,
    OBSGEN_TYPE ,
    OBSGEN_CODE ,
    OBSGEN_RESULT_QUAL ,
    OBSGEN_RESULT_TEXT ,
    OBSGEN_RESULT_NUM ,
    OBSGEN_RESULT_MODIFIER ,
    OBSGEN_RESULT_UNIT ,
    OBSGEN_TABLE_MODIFIED ,
    OBSGEN_ID_MODIFIED ,
    RAW_OBSGEN_NAME ,
    RAW_OBSGEN_CODE ,
    RAW_OBSGEN_TYPE ,
    RAW_OBSGEN_RESULT ,
    RAW_OBSGEN_UNIT
FROM cdm_in.OBS_GEN
;
