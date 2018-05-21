/*--------------------------------------------------------------------------------------\

AUTHORS :
 Initially Developed by Pedro Rivera, ADVANCE CDRN
 Contact information: Pedro Rivera (riverap@ochin.org), Jon Puro (puroj@ochin.org)
 Modified for CDM 4.1 by Jamie Estill, LHSNet CDRN

UPDATED :
 May 21, 2018

LICENSE :
 Shared on an "as is" basis without warranties or conditions of any kind.

DESCRIPTION: 
 This script creates SAS data files from SQL Server tables for the PCORnet CDM v. 4.1.
 The data files will be AES encrypted by default, and will be compressed.
 Developed with SAS 9.4 for use with SQL Server 2012.

VARIABLES:
 The program uses the following three variables that need to be set by the user.

dbdsn : DSN connection for the SQL server database that conains the source tables. 
        In windows this is set at the level of the operating system.
 Example: 
 %let dbdsn=pcori_dev_cdmv3_1;

dbschema : The schema in the SQL Server database that contains the source tables.
 Example :
 %let dbschema=pcori_cdmv4_1;

dpath : The path that the SAS data tables will be created at in the destination.
 Example :
 %let dpath=M:\pcori\pcori_test;

\--------------------------------------------------------------------------------------*/


/*
START OF EDITABLE CODE
*/

%let dbdsn=sqlpcorisqa_cdm4_1;     /* DSN for ODBC connection of host database. */
%let dbschema=pcori_cdmv4_1;       /* Schema name in host database. */
%let dpath=M:\pcori\pcori_test;    /* Directory where SAS files will be created. */ 

/*
END OF EDITABLE CODE
*/

LIBNAME cdm_in sqlsvr DSN=&dbdsn SCHEMA=&dbschema;
LIBNAME cdm_out "&dpath";


proc sql noprint;

create table cdm_out.CONDITION (compress=yes) as

SELECT CONDITIONID ,
       PATID ,
       ENCOUNTERID ,
       INPUT( PUT(REPORT_DATE , e8601da.) , e8601da.) AS REPORT_DATE format date9.,
       INPUT( PUT(RESOLVE_DATE , e8601da.) , e8601da.) AS RESOLVE_DATE format date9.,
       INPUT( PUT(ONSET_DATE , e8601da.) , e8601da.) AS ONSET_DATE format date9.,
       CONDITION_STATUS ,
       CONDITION ,
       CONDITION_TYPE ,
       CONDITION_SOURCE ,
       RAW_CONDITION_STATUS ,
       RAW_CONDITION ,
       RAW_CONDITION_TYPE ,
       RAW_CONDITION_SOURCE
FROM cdm_in.CONDITION
;

proc sql noprint;

create table cdm_out.DEATH (compress=yes) as

SELECT PATID ,
       INPUT( PUT(DEATH_DATE , e8601da.) , e8601da.) AS DEATH_DATE format date9.,
       DEATH_DATE_IMPUTE ,
       DEATH_SOURCE ,
       DEATH_MATCH_CONFIDENCE
FROM cdm_in.DEATH
;

proc sql noprint;

create table cdm_out.DEATH_CAUSE (compress=yes) as

SELECT PATID ,
       DEATH_CAUSE ,
       DEATH_CAUSE_CODE ,
       DEATH_CAUSE_TYPE ,
       DEATH_CAUSE_SOURCE ,
       DEATH_CAUSE_CONFIDENCE
FROM cdm_in.DEATH_CAUSE
;

proc sql noprint;

create table cdm_out.DEMOGRAPHIC (compress=yes) as

SELECT
    PATID , 
    INPUT( PUT(BIRTH_DATE , e8601da.) , e8601da.) AS BIRTH_DATE format date9., 
	INPUT( BIRTH_TIME , time.) AS BIRTH_TIME format hhmm.,
    SEX ,
	SEXUAL_ORIENTATION ,
	GENDER_IDENTITY ,
    HISPANIC ,
    RACE ,
    BIOBANK_FLAG ,
    PAT_PREF_LANGUAGE_SPOKEN ,
	RAW_SEX ,
	RAW_SEXUAL_ORIENTATION,
	RAW_GENDER_IDENTITY,
    RAW_HISPANIC ,
    RAW_RACE ,
	RAW_PAT_PREF_LANGUAGE_SPOKEN
FROM cdm_in.DEMOGRAPHIC
;

proc sql noprint;

create table cdm_out.DISPENSING (compress=yes) as

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

proc sql noprint;

create table cdm_out.DIAGNOSIS (compress=yes) as

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

proc sql noprint;

create table cdm_out.ENCOUNTER (compress=yes) as

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

proc sql noprint;

create table cdm_out.ENROLLMENT (compress=yes) as

SELECT PATID ,
       INPUT( PUT(ENR_START_DATE , e8601da.), e8601da.) AS ENR_START_DATE format date9.,
       INPUT( PUT(ENR_END_DATE , e8601da.), e8601da. ) AS ENR_END_DATE format date9.,
       CHART ,
       ENR_BASIS
FROM cdm_in.ENROLLMENT
;

proc sql noprint;

create table cdm_out.HARVEST (compress=yes) as

SELECT 
    NETWORKID ,
    NETWORK_NAME ,
    DATAMARTID ,
    DATAMART_NAME ,
    DATAMART_PLATFORM ,
    CDM_VERSION ,
    DATAMART_CLAIMS ,
    DATAMART_EHR ,
    BIRTH_DATE_MGMT ,
    ENR_START_DATE_MGMT ,
    ENR_END_DATE_MGMT ,
    ADMIT_DATE_MGMT ,
    DISCHARGE_DATE_MGMT ,
    PX_DATE_MGMT ,
    RX_ORDER_DATE_MGMT ,
    RX_START_DATE_MGMT ,
    RX_END_DATE_MGMT ,
    DISPENSE_DATE_MGMT ,
    LAB_ORDER_DATE_MGMT ,
    SPECIMEN_DATE_MGMT ,
    RESULT_DATE_MGMT ,
    MEASURE_DATE_MGMT ,
    ONSET_DATE_MGMT ,
    REPORT_DATE_MGMT ,
    RESOLVE_DATE_MGMT ,
    PRO_DATE_MGMT ,
    DEATH_DATE_MGMT ,
    MEDADMIN_START_DATE_MGMT ,
    MEDADMIN_STOP_DATE_MGMT ,
    OBSCLIN_DATE_MGMT ,
    OBSGEN_DATE_MGMT ,
    INPUT( PUT(REFRESH_DEMOGRAPHIC_DATE , e8601da.) , e8601da.) AS REFRESH_DEMOGRAPHIC_DATE format date9. ,
    INPUT( PUT(REFRESH_ENROLLMENT_DATE , e8601da.) , e8601da.) AS REFRESH_ENROLLMENT_DATE format date9. ,
	INPUT( PUT(REFRESH_ENCOUNTER_DATE , e8601da.) , e8601da.) AS REFRESH_ENCOUNTER_DATE format date9. ,
    INPUT( PUT(REFRESH_DIAGNOSIS_DATE , e8601da.) , e8601da.) AS REFRESH_DIAGNOSIS_DATE format date9. ,
    INPUT( PUT(REFRESH_PROCEDURES_DATE , e8601da.) , e8601da.) AS REFRESH_PROCEDURES_DATE format date9. ,
    INPUT( PUT(REFRESH_VITAL_DATE , e8601da.) , e8601da.) AS REFRESH_VITAL_DATE format date9. ,
    INPUT( PUT(REFRESH_DISPENSING_DATE , e8601da.) , e8601da.) AS REFRESH_DISPENSING_DATE format date9. ,
	INPUT( PUT(REFRESH_LAB_RESULT_CM_DATE , e8601da.) , e8601da.) AS REFRESH_LAB_RESULT_CM_DATE format date9. ,
    INPUT( PUT(REFRESH_CONDITION_DATE , e8601da.) , e8601da.) AS REFRESH_CONDITION_DATE format date9. ,
    INPUT( PUT(REFRESH_PRO_CM_DATE , e8601da.) , e8601da.) AS REFRESH_PRO_CM_DATE format date9. ,
	INPUT( PUT(REFRESH_PRESCRIBING_DATE , e8601da.) , e8601da.) AS REFRESH_PRESCRIBING_DATE format date9. ,
    INPUT( PUT(REFRESH_PCORNET_TRIAL_DATE , e8601da.) , e8601da.) AS REFRESH_PCORNET_TRIAL_DATE format date9. ,
    INPUT( PUT(REFRESH_DEATH_DATE , e8601da.) , e8601da.) AS REFRESH_DEATH_DATE format date9. ,
    INPUT( PUT(REFRESH_DEATH_CAUSE_DATE , e8601da.) , e8601da.) AS REFRESH_DEATH_CAUSE_DATE format date9. ,
	INPUT( PUT(REFRESH_MED_ADMIN_DATE , e8601da.) , e8601da.) AS REFRESH_MED_ADMIN_DATE format date9. ,
    INPUT( PUT(REFRESH_OBS_CLIN_DATE , e8601da.) , e8601da.) AS REFRESH_OBS_CLIN_DATE format date9. ,
    INPUT( PUT(REFRESH_PROVIDER_DATE , e8601da.) , e8601da.) AS REFRESH_PROVIDER_DATE format date9. ,
	INPUT( PUT(REFRESH_OBS_GEN_DATE , e8601da.) , e8601da.) AS REFRESH_OBS_GEN_DATE format date9.
FROM cdm_in.HARVEST
;

proc sql noprint;

create table cdm_out.LAB_RESULT_CM (compress=yes) as

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

proc sql noprint;

create table cdm_out.MED_ADMIN (compress=yes) as

SELECT 
    MEDADMINID ,
    PATID ,
    ENCOUNTERID ,
    PRESCRIBINGID ,
    MEDADMIN_PROVIDERID ,
    INPUT( PUT( MEDADMIN_START_DATE , e8601da.), e8601da.) AS MEDADMIN_START_DATE format date9. ,
	INPUT( MEDADMIN_START_TIME , time.) AS MEDADMIN_START_TIME format hhmm.,
    INPUT( PUT( MEDADMIN_STOP_DATE , e8601da.), e8601da.) AS MEDADMIN_STOP_DATE format date9.,
    INPUT( MEDADMIN_STOP_TIME , time.) AS MEDADMIN_STOP_TIME format hhmm.,
    MEDADMIN_TYPE ,
    MEDADMIN_CODE ,
    MEDADMIN_DOSE_ADMIN ,
    MEDADMIN_DOSE_ADMIN_UNIT ,
    MEDADMIN_ROUTE ,
    MEDADMIN_SOURCE ,
    RAW_MEDADMIN_MED_NAME ,
    RAW_MEDADMIN_CODE ,
    RAW_MEDADMIN_DOSE_ADMIN ,
    RAW_MEDADMIN_DOSE_ADMIN_UNIT ,
    RAW_MEDADMIN_ROUTE
FROM cdm_in.MED_ADMIN
;

proc sql noprint;

create table cdm_out.OBS_CLIN (compress=yes) as
SELECT 
    OBSCLINID ,
    PATID ,
    ENCOUNTERID ,
    OBSCLIN_PROVIDERID ,
    INPUT( PUT( OBSCLIN_DATE , e8601da.) , e8601da.) AS OBSCLIN_DATE format date9. ,
    INPUT( OBSCLIN_TIME , time.) AS OBSCLIN_TIME format hhmm. ,   
    OBSCLIN_TYPE ,
    OBSCLIN_CODE ,
    OBSCLIN_RESULT_QUAL ,
    OBSCLIN_RESULT_TEXT ,
    OBSCLIN_RESULT_SNOMED ,
    OBSCLIN_RESULT_NUM ,
    OBSCLIN_RESULT_MODIFIER ,
    OBSCLIN_RESULT_UNIT ,
    RAW_OBSCLIN_NAME ,
    RAW_OBSCLIN_CODE ,
    RAW_OBSCLIN_TYPE ,
    RAW_OBSCLIN_RESULT ,
    RAW_OBSCLIN_MODIFIER ,
    RAW_OBSCLIN_UNIT
FROM cdm_in.OBS_CLIN
;

proc sql noprint;

create table cdm_out.OBS_GEN (compress=yes) as
SELECT 
    OBSGENID ,
    PATID ,
    ENCOUNTERID ,
    OBSGEN_PROVIDERID ,
    INPUT( PUT( OBSGEN_DATE, e8601da.), e8601da.) AS OBSGEN_DATE format date9. ,
	INPUT( OBSGEN_TIME , time.) AS OBSGEN_TIME format hhmm. ,
    OBSGEN_TYPE ,
    OBSGEN_CODE ,
    OBSGEN_RESULT_QUAL ,
    OBSGEN_RESULT_TEXT ,
    OBSGEN_RESULT_NUM ,
    OBSGEN_RESULT_MODIFIER ,
    OBSGEN_RESULT_UNIT ,
    OBSGEN_TABLE_MODIFIED ,
    OBSGEN_ID_MODIFIED ,
    RAW_OBSGEN_NAME ,
    RAW_OBSGEN_CODE ,
    RAW_OBSGEN_TYPE ,
    RAW_OBSGEN_RESULT ,
    RAW_OBSGEN_UNIT
FROM cdm_in.OBS_GEN
;



proc sql noprint;

create table cdm_out.PCORNET_TRIAL (compress=yes) as

SELECT PATID ,
       TRIALID ,
       PARTICIPANTID ,
       TRIAL_SITEID ,
       INPUT( PUT(TRIAL_ENROLL_DATE , e8601da.) , e8601da.) AS TRIAL_ENROLL_DATE format date9.,
       INPUT( PUT(TRIAL_END_DATE , e8601da.) , e8601da.) AS TRIAL_END_DATE format date9.,
       INPUT( PUT(TRIAL_WITHDRAW_DATE , e8601da.) , e8601da.) AS TRIAL_WITHDRAW_DATE format date9.,
       TRIAL_INVITE_CODE
FROM cdm_in.PCORNET_TRIAL
;


proc sql noprint;

create table cdm_out.PRESCRIBING (compress=yes) as

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

proc sql noprint;

create table cdm_out.PRO_CM (compress=yes) as

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

proc sql noprint;

create table cdm_out.PROCEDURES (compress=yes) as

SELECT PROCEDURESID ,
       PATID ,
       ENCOUNTERID ,
       ENC_TYPE ,
       INPUT( PUT( ADMIT_DATE , e8601da.), e8601da.) AS ADMIT_DATE format date9.,
       PROVIDERID ,
       INPUT( PUT (PX_DATE , e8601da.), e8601da.) AS PX_DATE format date9.,
       PX ,
       PX_TYPE ,
       PX_SOURCE ,
	   PPX ,
       RAW_PX ,
       RAW_PX_TYPE ,
	   RAW_PPX
FROM cdm_in.PROCEDURES
;

proc sql noprint;

create table cdm_out.PROVIDER (compress=yes) as

SELECT 
    PROVIDERID ,
    PROVIDER_SEX ,
    PROVIDER_SPECIALTY_PRIMARY ,
    PROVIDER_NPI ,
    PROVIDER_NPI_FLAG ,
    RAW_PROVIDER_SPECIALTY_PRIMARY
FROM cdm_in.PROVIDER
;

proc sql noprint;

create table cdm_out.VITAL (compress=yes) as

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
