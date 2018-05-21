/*--------------------------------------------------------------------------------------\

CDM 4.1 ENROLLMENT TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.ENROLLMENT (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT PATID ,
       INPUT( PUT(ENR_START_DATE , e8601da.), e8601da.) AS ENR_START_DATE format date9.,
       INPUT( PUT(ENR_END_DATE , e8601da.), e8601da. ) AS ENR_END_DATE format date9.,
       CHART ,
       ENR_BASIS
FROM cdm_in.ENROLLMENT
;

