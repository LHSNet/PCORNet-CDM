/*--------------------------------------------------------------------------------------\

CDM 4.1 PRESCRIBING TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.PRESCRIBING (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT PRESCRIBINGID ,
       PATID ,
       ENCOUNTERID ,
       RX_PROVIDERID ,
       INPUT( PUT(RX_ORDER_DATE , e8601da.) , e8601da.) AS RX_ORDER_DATE format date9.,
       INPUT( RX_ORDER_TIME , time.) AS RX_ORDER_TIME format hhmm.,
       INPUT( PUT(RX_START_DATE , e8601da.) , e8601da.) AS RX_START_DATE format date9.,
       INPUT( PUT(RX_END_DATE , e8601da.) , e8601da.) AS RX_END_DATE format date9.,
	   RX_DOSE_ORDERED,
	   RX_DOSE_ORDERED_UNIT,
       RX_QUANTITY ,
	   RX_DOSE_FORM,
       RX_REFILLS ,
       RX_DAYS_SUPPLY ,
       RX_FREQUENCY ,
	   RX_PRN_FLAG,
	   RX_ROUTE,
       RX_BASIS ,
       RXNORM_CUI ,
	   RX_SOURCE ,
	   RX_DISPENSE_AS_WRITTEN ,
       RAW_RX_MED_NAME ,
       RAW_RX_FREQUENCY ,
       RAW_RXNORM_CUI ,
       RAW_RX_QUANTITY ,
	   RAW_RX_NDC ,
	   RAW_RX_DOSE_ORDERED ,
	   RAW_RX_DOSE_ORDERED_UNIT ,
	   RAW_RX_ROUTE ,
	   RAW_RX_REFILLS
FROM cdm_in.PRESCRIBING
;
