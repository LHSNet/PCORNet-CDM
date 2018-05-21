/*--------------------------------------------------------------------------------------\

CDM 4.1 LAB_RESULT_CM TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.LAB_RESULT_CM (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT LAB_RESULT_CM_ID ,
       PATID ,
       ENCOUNTERID ,
       LAB_NAME ,
       SPECIMEN_SOURCE ,
       LAB_LOINC ,
       PRIORITY ,
       RESULT_LOC ,
       LAB_PX ,
       LAB_PX_TYPE ,
       INPUT( PUT(LAB_ORDER_DATE , e8601da.) , e8601da.) AS LAB_ORDER_DATE format date9.,
       INPUT( PUT(SPECIMEN_DATE , e8601da.) , e8601da.) AS SPECIMEN_DATE format date9.,
       INPUT( SPECIMEN_TIME , time.) AS SPECIMEN_TIME format hhmm.,
       INPUT( PUT(RESULT_DATE , e8601da.) , e8601da.) AS RESULT_DATE format date9.,
       INPUT( RESULT_TIME , time.) AS RESULT_TIME format hhmm.,
       RESULT_QUAL ,
	   RESULT_SNOMED ,
       RESULT_NUM , 
       RESULT_MODIFIER ,
       RESULT_UNIT ,
       NORM_RANGE_LOW ,
       NORM_MODIFIER_LOW ,
       NORM_RANGE_HIGH ,
       NORM_MODIFIER_HIGH ,
       ABN_IND ,
	   RAW_LAB_NAME ,
	   RAW_LAB_CODE ,
	   RAW_PANEL ,
	   RAW_RESULT ,
	   RAW_UNIT ,
	   RAW_ORDER_DEPT ,
	   RAW_FACILITY_CODE
FROM cdm_in.LAB_RESULT_CM
;
