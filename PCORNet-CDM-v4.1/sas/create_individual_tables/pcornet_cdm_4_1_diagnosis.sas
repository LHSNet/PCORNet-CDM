/*--------------------------------------------------------------------------------------\

CDM 4.1 DIAGNOSIS TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.DIAGNOSIS (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT DIAGNOSISID ,
       PATID ,
       ENCOUNTERID ,
       ENC_TYPE ,
	   INPUT( PUT(ADMIT_DATE, e8601da.), e8601da.) AS ADMIT_DATE format date9.,
       PROVIDERID ,
       DX ,
       DX_TYPE ,
       DX_SOURCE ,
	   DX_ORIGIN,
       PDX ,
	   DX_POA ,
       RAW_DX ,
       RAW_DX_TYPE ,
       RAW_DX_SOURCE ,
       RAW_PDX ,
	   RAW_DX_POA
FROM cdm_in.DIAGNOSIS
;
