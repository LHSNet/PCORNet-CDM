/*--------------------------------------------------------------------------------------\

CDM 4.1 CONDITION TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.CONDITION (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT CONDITIONID ,
       PATID ,
       ENCOUNTERID ,
       INPUT( PUT(REPORT_DATE , e8601da.) , e8601da.) AS REPORT_DATE format date9.,
       INPUT( PUT(RESOLVE_DATE , e8601da.) , e8601da.) AS RESOLVE_DATE format date9.,
       INPUT( PUT(ONSET_DATE , e8601da.) , e8601da.) AS ONSET_DATE format date9.,
       CONDITION_STATUS ,
       CONDITION ,
       CONDITION_TYPE ,
       CONDITION_SOURCE ,
       RAW_CONDITION_STATUS ,
       RAW_CONDITION ,
       RAW_CONDITION_TYPE ,
       RAW_CONDITION_SOURCE
FROM cdm_in.CONDITION
;

