/*--------------------------------------------------------------------------------------\

CDM 4.1 ENCOUNTER TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.ENCOUNTER (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT ENCOUNTERID ,
       PATID,
	   INPUT( PUT( ADMIT_DATE , e8601da.), e8601da.) AS ADMIT_DATE format date9.,
	   INPUT( ADMIT_TIME , time.) AS ADMIT_TIME format hhmm.,
       INPUT( PUT( DISCHARGE_DATE , e8601da.), e8601da. ) AS DISCHARGE_DATE format date9.,
	   INPUT( DISCHARGE_TIME , time.) AS DISCHARGE_TIME format hhmm.,
	   PROVIDERID ,
       FACILITY_LOCATION ,
       ENC_TYPE ,
       FACILITYID ,
       DISCHARGE_DISPOSITION ,
       DISCHARGE_STATUS ,
       DRG,
       DRG_TYPE ,
       ADMITTING_SOURCE ,
	   PAYER_TYPE_PRIMARY ,
	   PAYER_TYPE_SECONDARY ,
	   FACILITY_TYPE ,
       RAW_SITEID ,
       RAW_ENC_TYPE ,
       RAW_DISCHARGE_DISPOSITION ,
       RAW_DISCHARGE_STATUS ,
       RAW_DRG_TYPE ,
       RAW_ADMITTING_SOURCE ,
	   RAW_FACILITY_TYPE ,
	   RAW_PAYER_TYPE_PRIMARY ,
	   RAW_PAYER_NAME_PRIMARY ,
	   RAW_PAYER_ID_PRIMARY ,
	   RAW_PAYER_TYPE_SECONDARY ,
	   RAW_PAYER_NAME_SECONDARY ,
	   RAW_PAYER_ID_SECONDARY
FROM cdm_in.ENCOUNTER
;

