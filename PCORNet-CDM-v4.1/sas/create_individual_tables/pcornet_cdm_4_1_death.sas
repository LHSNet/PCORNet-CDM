/*--------------------------------------------------------------------------------------\

CDM 4.1 DEATH TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.DEATH (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT PATID ,
       INPUT( PUT(DEATH_DATE , e8601da.) , e8601da.) AS DEATH_DATE format date9.,
       DEATH_DATE_IMPUTE ,
       DEATH_SOURCE ,
       DEATH_MATCH_CONFIDENCE
FROM cdm_in.DEATH
;
