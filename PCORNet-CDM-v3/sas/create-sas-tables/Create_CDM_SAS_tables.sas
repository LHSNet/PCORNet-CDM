/*--------------------------------------------------------------------------------------\

Developed by Pedro Rivera, ADVANCE CDRN
Contact information: Pedro Rivera (riverap@ochin.org), Jon Puro (puroj@ochin.org)
Shared on an "as is" basis without warranties or conditions of any kind.
Developed with SAS 9.4 for use with SQL Server 2012.

Purpose: This script creates SAS data files from SQL Server tables for the PCORnet CDM v. 3.0.

\--------------------------------------------------------------------------------------*/

LIBNAME cdm_in sqlsvr DSN=pcori_cdmv3 USER=******* PASSWORD=************ SCHEMA=pcori_cdmv3;
LIBNAME cdm_out "c:/sasroot/pcori/cdmv3/sas_export/";

proc sql noprint;

create table cdm_out.DEMOGRAPHIC (compress=yes) as

SELECT
    PATID ,
    INPUT( PUT(BIRTH_DATE , e8601da.) , e8601da.) AS BIRTH_DATE format date9.,
    INPUT( BIRTH_TIME , time.) AS BIRTH_TIME format hhmm.,
    SEX ,
    HISPANIC ,
    RACE ,
    BIOBANK_FLAG ,
    RAW_SEX ,
    RAW_HISPANIC ,
    RAW_RACE
FROM cdm_in.DEMOGRAPHIC
;


proc sql noprint;

create table cdm_out.ENCOUNTER (compress=yes) as

SELECT ENCOUNTERID ,
       PATID ,
       INPUT( PUT(ADMIT_DATE , e8601da.) , e8601da.) AS ADMIT_DATE format date9.,
       INPUT( ADMIT_TIME , time.) AS ADMIT_TIME format hhmm.,
       INPUT( PUT(DISCHARGE_DATE , e8601da.) , e8601da.) AS DISCHARGE_DATE format date9.,
       INPUT( DISCHARGE_TIME , time.) AS DISCHARGE_TIME format hhmm.,
       PROVIDERID ,
       FACILITY_LOCATION ,
       ENC_TYPE ,
       FACILITYID ,
       DISCHARGE_DISPOSITION ,
       DISCHARGE_STATUS ,
       DRG ,
       DRG_TYPE ,
       ADMITTING_SOURCE ,
       RAW_SITEID ,
       RAW_ENC_TYPE ,
       RAW_DISCHARGE_DISPOSITION ,
       RAW_DISCHARGE_STATUS ,
       RAW_DRG_TYPE ,
       RAW_ADMITTING_SOURCE
FROM cdm_in.ENCOUNTER
;



proc sql noprint;

create table cdm_out.DIAGNOSIS (compress=yes) as

SELECT DIAGNOSISID ,
       PATID ,
       ENCOUNTERID ,
       ENC_TYPE ,
       INPUT( PUT(ADMIT_DATE , e8601da.) , e8601da.) AS ADMIT_DATE format date9.,
       PROVIDERID ,
       DX ,
       DX_TYPE ,
       DX_SOURCE ,
       PDX ,
       RAW_DX ,
       RAW_DX_TYPE ,
       RAW_DX_SOURCE ,
       RAW_PDX
FROM cdm_in.DIAGNOSIS
;

proc sql noprint;

create table cdm_out.PROCEDURES (compress=yes) as

SELECT PROCEDURESID ,
       PATID ,
       ENCOUNTERID ,
       ENC_TYPE ,
       INPUT( PUT(ADMIT_DATE , e8601da.) , e8601da.) AS ADMIT_DATE format date9.,
       PROVIDERID ,
       INPUT( PUT(PX_DATE , e8601da.) , e8601da.) AS PX_DATE format date9.,
       PX ,
       PX_TYPE ,
       PX_SOURCE ,
       RAW_PX ,
       RAW_PX_TYPE
FROM cdm_in.PROCEDURES
;


proc sql noprint;

create table cdm_out.PRO_CM (compress=yes) as

SELECT PRO_CM_ID ,
       PATID ,
       ENCOUNTERID ,
       PRO_ITEM ,
       PRO_LOINC ,
       INPUT( PUT(PRO_DATE , e8601da.) , e8601da.) AS PRO_DATE format date9.,
       INPUT( PRO_TIME , time.) AS PRO_TIME format hhmm.,
       PRO_RESPONSE ,
       PRO_METHOD ,
       PRO_MODE ,
       PRO_CAT ,
       RAW_PRO_CODE ,
       RAW_PRO_RESPONSE
FROM cdm_in.PRO_CM
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
       RX_QUANTITY ,
       RX_REFILLS ,
       RX_DAYS_SUPPLY ,
       RX_FREQUENCY ,
       RX_BASIS ,
       RXNORM_CUI ,
       RAW_RX_FREQUENCY ,
       RAW_RX_MED_NAME ,
       RAW_RXNORM_CUI
FROM cdm_in.PRESCRIBING
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
       RAW_NDC
FROM cdm_in.DISPENSING
;


proc sql noprint;

create table cdm_out.VITAL (compress=yes) as

SELECT VITALID ,
       PATID ,
       ENCOUNTERID ,
       INPUT( PUT(MEASURE_DATE , e8601da.) , e8601da.) AS MEASURE_DATE format date9.,
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
       RAW_BP_POSITION ,
       RAW_SYSTOLIC ,
       RAW_DIASTOLIC ,
       RAW_SMOKING ,
       RAW_TOBACCO ,
       RAW_TOBACCO_TYPE
FROM cdm_in.VITAL
;

proc sql noprint;

create table cdm_out.LAB_RESULT_CM (compress=yes) as

SELECT
         LAB_RESULT_CM_ID ,
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
       PUT(RESULT_NUM, z20.10) AS RESULT_NUM , /* This RDBMS-SAS data type discrepancy is an issue being addressed by the coordinating center (sould be a SAS number)  */
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

create table cdm_out.ENROLLMENT (compress=yes) as

SELECT PATID ,
       INPUT( PUT(ENR_START_DATE , e8601da.) , e8601da.) AS ENR_START_DATE format date9.,
       INPUT( PUT(ENR_END_DATE , e8601da.) , e8601da.) AS ENR_END_DATE format date9.,
       CHART ,
       ENR_BASIS
FROM cdm_in.ENROLLMENT
;


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

create table cdm_out.HARVEST (compress=yes) as

SELECT NETWORKID ,
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
       INPUT( PUT(REFRESH_DEMOGRAPHIC_DATE , e8601da.) , e8601da.) AS REFRESH_DEMOGRAPHIC_DATE format date9.,
       INPUT( PUT(REFRESH_ENROLLMENT_DATE , e8601da.) , e8601da.) AS REFRESH_ENROLLMENT_DATE format date9.,
       INPUT( PUT(REFRESH_ENCOUNTER_DATE , e8601da.) , e8601da.) AS REFRESH_ENCOUNTER_DATE format date9.,
       INPUT( PUT(REFRESH_DIAGNOSIS_DATE , e8601da.) , e8601da.) AS REFRESH_DIAGNOSIS_DATE format date9.,
       INPUT( PUT(REFRESH_PROCEDURES_DATE , e8601da.) , e8601da.) AS REFRESH_PROCEDURES_DATE format date9.,
       INPUT( PUT(REFRESH_VITAL_DATE , e8601da.) , e8601da.) AS REFRESH_VITAL_DATE format date9.,
       INPUT( PUT(REFRESH_DISPENSING_DATE , e8601da.) , e8601da.) AS REFRESH_DISPENSING_DATE format date9.,
       INPUT( PUT(REFRESH_LAB_RESULT_CM_DATE , e8601da.) , e8601da.) AS REFRESH_LAB_RESULT_CM_DATE format date9.,
       INPUT( PUT(REFRESH_CONDITION_DATE , e8601da.) , e8601da.) AS REFRESH_CONDITION_DATE format date9.,
       INPUT( PUT(REFRESH_PRO_CM_DATE , e8601da.) , e8601da.) AS REFRESH_PRO_CM_DATE format date9.,
       INPUT( PUT(REFRESH_PRESCRIBING_DATE , e8601da.) , e8601da.) AS REFRESH_PRESCRIBING_DATE format date9.,
       INPUT( PUT(REFRESH_PCORNET_TRIAL_DATE , e8601da.) , e8601da.) AS REFRESH_PCORNET_TRIAL_DATE format date9.,
       INPUT( PUT(REFRESH_DEATH_DATE , e8601da.) , e8601da.) AS REFRESH_DEATH_DATE format date9.,
       INPUT( PUT(REFRESH_DEATH_CAUSE_DATE , e8601da.), e8601da.) AS REFRESH_DEATH_CAUSE_DATE format date9.
FROM cdm_in.HARVEST
;
