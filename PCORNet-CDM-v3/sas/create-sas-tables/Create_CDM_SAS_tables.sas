/*--------------------------------------------------------------------------------------\

Developed by Pedro Rivera, ADVANCE CDRN
Contact information: Pedro Rivera (riverap@ochin.org), Jon Puro (puroj@ochin.org)
Shared on an "as is" basis without warranties or conditions of any kind.
Developed with SAS 9.4 for use with SQL Server 2012.

Purpose: This script creates SAS data files from SQL Server tables for the PCORnet CDM v. 3.0.

\--------------------------------------------------------------------------------------*/


libname cdm "e:/sasroot/ADVANCE_CDM/";

proc sql noprint; 

create table cdm.DEMOGRAPHIC (compress=yes) as

SELECT 
	PATID ,
	INPUT( BIRTH_DATE , e8601da.) AS BIRTH_DATE format date9.,
	INPUT( BIRTH_TIME , time10.) AS BIRTH_TIME format hhmm.,
    SEX ,
    HISPANIC ,
    RACE ,
    BIOBANK_FLAG ,
    RAW_SEX ,
    RAW_HISPANIC ,
    RAW_RACE 
FROM ADVCDM.DEMOGRAPHIC
;


proc sql noprint; 

create table cdm.ENCOUNTER (compress=yes) as

SELECT ENCOUNTERID ,
       PATID ,
	   INPUT( ADMIT_DATE , e8601da.) AS ADMIT_DATE format date9.,
	   INPUT( ADMIT_TIME , time10.) AS ADMIT_TIME format hhmm.,
	   INPUT( DISCHARGE_DATE , e8601da.) AS DISCHARGE_DATE format date9.,
	   INPUT( DISCHARGE_TIME , time10.) AS DISCHARGE_TIME format hhmm.,
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
FROM ADVCDM.ENCOUNTER
;



proc sql noprint; 

create table cdm.DIAGNOSIS (compress=yes) as

SELECT DIAGNOSISID ,
       PATID ,
       ENCOUNTERID ,
       ENC_TYPE ,
       INPUT( ADMIT_DATE , e8601da.) AS ADMIT_DATE format date9.,
       PROVIDERID ,
       DX ,
       DX_TYPE ,
       DX_SOURCE ,
       PDX ,
       RAW_DX ,
       RAW_DX_TYPE ,
       RAW_DX_SOURCE ,
       RAW_PDX 
FROM ADVCDM.DIAGNOSIS
;

proc sql noprint; 

create table cdm.PROCEDURES (compress=yes) as

SELECT PROCEDURESID ,
       PATID ,
       ENCOUNTERID ,
       ENC_TYPE ,
       INPUT( ADMIT_DATE , e8601da.) AS ADMIT_DATE format date9.,
       PROVIDERID ,
	   INPUT( PX_DATE , e8601da.) AS PX_DATE format date9.,
       PX ,
       PX_TYPE ,
       PX_SOURCE ,
       RAW_PX ,
       RAW_PX_TYPE 
FROM ADVCDM.PROCEDURES
;


proc sql noprint; 

create table cdm.PRO_CM (compress=yes) as

SELECT PRO_CM_ID ,
       PATID ,
       ENCOUNTERID ,
       PRO_ITEM ,
       PRO_LOINC ,
	   INPUT( PRO_DATE , e8601da.) AS PRO_DATE format date9.,
	   INPUT( PRO_TIME , time10.) AS PRO_TIME format hhmm.,
       PRO_RESPONSE ,
       PRO_METHOD ,
       PRO_MODE ,
       PRO_CAT ,
       RAW_PRO_CODE ,
       RAW_PRO_RESPONSE 
FROM ADVCDM.PRO_CM
;

proc sql noprint; 

create table cdm.PRESCRIBING (compress=yes) as

SELECT PRESCRIBINGID ,
       PATID ,
       ENCOUNTERID ,
       RX_PROVIDERID ,
	   INPUT( RX_ORDER_DATE , e8601da.) AS RX_ORDER_DATE format date9.,
	   INPUT( RX_ORDER_TIME , time10.) AS RX_ORDER_TIME format hhmm.,
	   INPUT( RX_START_DATE , e8601da.) AS RX_START_DATE format date9.,
	   INPUT( RX_END_DATE , e8601da.) AS RX_END_DATE format date9.,
       RX_QUANTITY ,
       RX_REFILLS ,
       RX_DAYS_SUPPLY ,
       RX_FREQUENCY ,
       RX_BASIS ,
       RXNORM_CUI ,
       RAW_RX_FREQUENCY ,
       RAW_RX_MED_NAME ,
       RAW_RXNORM_CUI
FROM ADVCDM.PRESCRIBING
;

proc sql noprint; 

create table cdm.DISPENSING (compress=yes) as

SELECT DISPENSINGID ,
       PATID ,
       PRESCRIBINGID ,
	   INPUT( DISPENSE_DATE , e8601da.) AS DISPENSE_DATE format date9.,
       NDC ,
       DISPENSE_SUP ,
       DISPENSE_AMT ,
       RAW_NDC 
FROM ADVCDM.DISPENSING
;


proc sql noprint; 

create table cdm.VITAL (compress=yes) as

SELECT VITALID ,
       PATID ,
       ENCOUNTERID ,
	   INPUT( MEASURE_DATE , e8601da.) AS MEASURE_DATE format date9.,
	   INPUT( MEASURE_TIME , time10.) AS MEASURE_TIME format hhmm.,
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
FROM ADVCDM.VITAL
;

proc sql noprint; 

create table cdm.LAB_RESULT_CM (compress=yes) as

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
	   INPUT( LAB_ORDER_DATE , e8601da.) AS LAB_ORDER_DATE format date9.,
	   INPUT( SPECIMEN_DATE , e8601da.) AS SPECIMEN_DATE format date9.,
	   INPUT( SPECIMEN_TIME , time10.) AS SPECIMEN_TIME format hhmm.,
	   INPUT( RESULT_DATE , e8601da.) AS RESULT_DATE format date9.,
	   INPUT( RESULT_TIME , time10.) AS RESULT_TIME format hhmm., 
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
FROM ADVCDM.LAB_RESULT_CM
;

proc sql noprint; 

create table cdm.ENROLLMENT (compress=yes) as

SELECT PATID ,
       INPUT( ENR_START_DATE , e8601da.) AS ENR_START_DATE format date9.,
       INPUT( ENR_END_DATE , e8601da.) AS ENR_END_DATE format date9.,  
       CHART ,
       ENR_BASIS 
FROM ADVCDM.ENROLLMENT
;


proc sql noprint; 

create table cdm.CONDITION (compress=yes) as

SELECT CONDITIONID ,
       PATID ,
       ENCOUNTERID ,
	   INPUT( REPORT_DATE , e8601da.) AS REPORT_DATE format date9.,
	   INPUT( RESOLVE_DATE , e8601da.) AS RESOLVE_DATE format date9.,
       INPUT( ONSET_DATE , e8601da.) AS ONSET_DATE format date9.,
       CONDITION_STATUS ,
       CONDITION ,
       CONDITION_TYPE ,
       CONDITION_SOURCE ,
       RAW_CONDITION_STATUS ,
       RAW_CONDITION ,
       RAW_CONDITION_TYPE ,
       RAW_CONDITION_SOURCE 
FROM ADVCDM.CONDITION
;


proc sql noprint; 

create table cdm.PCORNET_TRIAL (compress=yes) as

SELECT PATID ,
       TRIALID ,
       PARTICIPANTID ,
       TRIAL_SITEID ,
       INPUT( TRIAL_ENROLL_DATE , e8601da.) AS TRIAL_ENROLL_DATE format date9.,
       INPUT( TRIAL_END_DATE , e8601da.) AS TRIAL_END_DATE format date9.,
	   INPUT( TRIAL_WITHDRAW_DATE , e8601da.) AS TRIAL_WITHDRAW_DATE format date9.,
       TRIAL_INVITE_CODE
FROM ADVCDM.PCORNET_TRIAL
;


proc sql noprint; 

create table cdm.DEATH (compress=yes) as

SELECT PATID ,
       INPUT( DEATH_DATE , e8601da.) AS DEATH_DATE format date9.,
       DEATH_DATE_IMPUTE ,
       DEATH_SOURCE ,
       DEATH_MATCH_CONFIDENCE 
FROM ADVCDM.DEATH
;

proc sql noprint; 

create table cdm.DEATH_CAUSE (compress=yes) as

SELECT PATID ,
       DEATH_CAUSE ,
       DEATH_CAUSE_CODE ,
       DEATH_CAUSE_TYPE ,
       DEATH_CAUSE_SOURCE ,
       DEATH_CAUSE_CONFIDENCE 
FROM ADVCDM.DEATH_CAUSE
;



proc sql noprint; 

create table cdm.HARVEST (compress=yes) as

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
	   INPUT( REFRESH_DEMOGRAPHIC_DATE , e8601da.) AS REFRESH_DEMOGRAPHIC_DATE format date9.,
	   INPUT( REFRESH_ENROLLMENT_DATE , e8601da.) AS REFRESH_ENROLLMENT_DATE format date9.,
	   INPUT( REFRESH_ENCOUNTER_DATE , e8601da.) AS REFRESH_ENCOUNTER_DATE format date9.,
	   INPUT( REFRESH_DIAGNOSIS_DATE , e8601da.) AS REFRESH_DIAGNOSIS_DATE format date9.,
	   INPUT( REFRESH_PROCEDURES_DATE , e8601da.) AS REFRESH_PROCEDURES_DATE format date9.,
	   INPUT( REFRESH_VITAL_DATE , e8601da.) AS REFRESH_VITAL_DATE format date9.,
	   INPUT( REFRESH_DISPENSING_DATE , e8601da.) AS REFRESH_DISPENSING_DATE format date9.,
	   INPUT( REFRESH_LAB_RESULT_CM_DATE , e8601da.) AS REFRESH_LAB_RESULT_CM_DATE format date9.,
	   INPUT( REFRESH_CONDITION_DATE , e8601da.) AS REFRESH_CONDITION_DATE format date9.,
	   INPUT( REFRESH_PRO_CM_DATE , e8601da.) AS REFRESH_PRO_CM_DATE format date9.,
	   INPUT( REFRESH_PRESCRIBING_DATE , e8601da.) AS REFRESH_PRESCRIBING_DATE format date9.,
	   INPUT( REFRESH_PCORNET_TRIAL_DATE , e8601da.) AS REFRESH_PCORNET_TRIAL_DATE format date9.,
	   INPUT( REFRESH_DEATH_DATE , e8601da.) AS REFRESH_DEATH_DATE format date9.,
	   INPUT( REFRESH_DEATH_CAUSE_DATE, e8601da.) AS REFRESH_DEATH_CAUSE_DATE format date9.
FROM ADVCDM.HARVEST
;

