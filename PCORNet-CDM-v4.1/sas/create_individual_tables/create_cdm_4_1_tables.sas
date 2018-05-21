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
 The program uses the following five variables that need to be set by the user.

aeskey : String that will be used as the AES encryption key.
 Example: %let aeskey=AL0ngKeyThatC4nNotB3Guessed!!; 

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

qpath : The path that holds this SAS program and all table creation SAS programs. 
 Example :
 %let qpath=M:\pcori\create_individual_tables;
\--------------------------------------------------------------------------------------*/


/*
START OF EDITABLE CODE
*/
%let aeskey=test;                                                           /* AES encryption key. */
%let dbdsn=sqlpcorisqa_cdm4_1;                                              /* DSN for ODBC connection of host database. */
%let dbschema=pcori_cdmv4_1;                                                /* Schema name in host database. */
%let dpath=M:\pcori\pcori_test_data;                                        /* Directory where encrypted SAS files will be created. */ 
%let qpath=M:\pcori\create_individual_tables;                               /* Directory where this code exists */

/*
END OF EDITABLE CODE
*/

/* SET LIBNAME FOR DATA IN AND DATA OUT*/
LIBNAME cdm_in sqlsvr DSN=&dbdsn SCHEMA=&dbschema;
LIBNAME cdm_out "&dpath";


/* CREATE INDIVIDUAL TABLES */
%include "&qpath\pcornet_cdm_4_1_condition.sas";
%include "&qpath\pcornet_cdm_4_1_death.sas";
%include "&qpath\pcornet_cdm_4_1_death_cause.sas";
%include "&qpath\pcornet_cdm_4_1_demographic.sas";
%include "&qpath\pcornet_cdm_4_1_dispensing.sas";
%include "&qpath\pcornet_cdm_4_1_diagnosis.sas";
%include "&qpath\pcornet_cdm_4_1_encounter.sas";
%include "&qpath\pcornet_cdm_4_1_enrollment.sas";
%include "&qpath\pcornet_cdm_4_1_harvest.sas";
%include "&qpath\pcornet_cdm_4_1_lab_result_cm.sas";
%include "&qpath\pcornet_cdm_4_1_med_admin.sas";
%include "&qpath\pcornet_cdm_4_1_obs_clin.sas";
%include "&qpath\pcornet_cdm_4_1_obs_gen.sas";
%include "&qpath\pcornet_cdm_4_1_pcornet_trial.sas";
%include "&qpath\pcornet_cdm_4_1_prescribing.sas";
%include "&qpath\pcornet_cdm_4_1_pro_cm.sas";
%include "&qpath\pcornet_cdm_4_1_procedures.sas";
%include "&qpath\pcornet_cdm_4_1_provider.sas";
%include "&qpath\pcornet_cdm_4_1_vital.sas";
