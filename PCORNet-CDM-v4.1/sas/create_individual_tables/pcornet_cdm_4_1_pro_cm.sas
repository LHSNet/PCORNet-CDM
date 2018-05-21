/*--------------------------------------------------------------------------------------\

CDM 4.1 PRO_CM TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.PRO_CM (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT PRO_CM_ID ,
       PATID ,
       ENCOUNTERID ,
	   INPUT( PUT(PRO_DATE , e8601da.) , e8601da.) AS PRO_DATE format date9. ,
       INPUT( PRO_TIME , time.) AS PRO_TIME format hhmm. ,
       PRO_TYPE ,
       PRO_ITEM_NAME ,
       PRO_ITEM_LOINC ,
       PRO_RESPONSE_TEXT ,
       PRO_RESPONSE_NUM ,
       PRO_METHOD ,
       PRO_MODE ,
       PRO_CAT ,
       PRO_ITEM_VERSION ,
       PRO_MEASURE_NAME ,
       PRO_MEASURE_SEQ ,
       PRO_MEASURE_SCORE ,
       PRO_MEASURE_THETA ,
       PRO_MEASURE_SCALED_TSCORE ,
       PRO_MEASURE_STANDARD_ERROR ,
       PRO_MEASURE_COUNT_SCORED ,
       PRO_MEASURE_LOINC ,
       PRO_MEASURE_VERSION ,
       PRO_ITEM_FULLNAME ,
       PRO_ITEM_TEXT ,
       PRO_MEASURE_FULLNAME
FROM cdm_in.PRO_CM
;


