/*--------------------------------------------------------------------------------------\

CDM 4.1 DISPENSING TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.DISPENSING (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT DISPENSINGID ,
       PATID ,
       PRESCRIBINGID ,
       INPUT( PUT(DISPENSE_DATE , e8601da.) , e8601da.) AS DISPENSE_DATE format date9.,
       NDC ,
       DISPENSE_SUP ,
       DISPENSE_AMT ,
	   DISPENSE_DOSE_DISP ,
	   DISPENSE_DOSE_DISP_UNIT ,
	   DISPENSE_ROUTE ,
       RAW_NDC ,
	   RAW_DISPENSE_DOSE_DISP ,
	   RAW_DISPENSE_DOSE_UNIT ,
	   RAW_DISPENSE_ROUTE ,
       RAW_DISPENSE_DOSE_DISP_UNIT
FROM cdm_in.DISPENSING
;

