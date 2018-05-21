/*--------------------------------------------------------------------------------------\

CDM 4.1 DEATH_CAUSE TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.DEATH_CAUSE (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT PATID ,
       DEATH_CAUSE ,
       DEATH_CAUSE_CODE ,
       DEATH_CAUSE_TYPE ,
       DEATH_CAUSE_SOURCE ,
       DEATH_CAUSE_CONFIDENCE
FROM cdm_in.DEATH_CAUSE
;
