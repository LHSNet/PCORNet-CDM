/*--------------------------------------------------------------------------------------\

CDM 4.1 VITAL TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.VITAL (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT VITALID ,
       PATID ,
       ENCOUNTERID ,
       INPUT( PUT(MEASURE_DATE , e8601da.), e8601da.) AS MEASURE_DATE format date9.,
       INPUT( MEASURE_TIME , time.) AS MEASURE_TIME format hhmm.,
       VITAL_SOURCE ,
       HT ,
       WT ,
       DIASTOLIC ,
       SYSTOLIC ,
       ORIGINAL_BMI ,
       BP_POSITION ,
       SMOKING ,
       TOBACCO ,
       TOBACCO_TYPE ,
	   RAW_DIASTOLIC ,
       RAW_SYSTOLIC ,
	   RAW_BP_POSITION ,
       RAW_SMOKING ,
       RAW_TOBACCO ,
       RAW_TOBACCO_TYPE
FROM cdm_in.VITAL
;

