-- PCORnet Commond Data Model v3.0
-- Model 2015-07-29

--  SCHEMA : PCORI_CDMV3
--  AUTHOR : James Estill
-- UPDATED : AUG 25, 2015

-- LICENSE : Apache License v 2.0
--           http://www.apache.org/licenses/LICENSE-2.0

CREATE TABLE PCORI_CDMV3.DEMOGRAPHIC (
  PATID          VARCHAR(50) NOT NULL PRIMARY KEY, 
  BIRTH_DATE     DATE, 
  BIRTH_TIME     CHAR(5), 
  SEX            VARCHAR(2), 
  HISPANIC       VARCHAR(2), 
  RACE           CHAR(2), 
  BIOBANK_FLAG   CHAR(1), 
  RAW_SEX        VARCHAR,
  RAW_HISPANIC   VARCHAR,
  RAW_RACE       VARCHAR
);


CREATE TABLE PCORI_CDMV3.ENROLLMENT (
  PATID           VARCHAR(50) NOT NULL,
  ENR_START_DATE  DATE NOT NULL,
  ENR_END_DATE    DATE,
  CHART           CHAR(1),
  ENR_BASIS       CHAR(1) NOT NULL,
  PRIMARY KEY     (PATID, ENR_START_DATE, ENR_BASIS)
);


CREATE TABLE PCORI_CDMV3.ENCOUNTER (
  ENCOUNTERID                 VARCHAR(50) NOT NULL PRIMARY KEY,
  PATID                       VARCHAR(50) NOT NULL,
  ADMIT_DATE                  DATE NOT NULL,
  ADMIT_TIME                  CHAR(5),
  DISCHARGE_DATE              DATE,
  DISCHARGE_TIME              CHAR(5),
  PROVIDERID                  VARCHAR(50),
  FACILITY_LOCATION           VARCHAR,
  ENC_TYPE                    CHAR(2) NOT NULL,
  FACILITYID                  VARCHAR,
  DISCHARGE_DISPOSITION       VARCHAR(2),
  DISCHARGE_STATUS            CHAR(2),
  DRG                         VARCHAR(3),
  DRG_TYPE                    CHAR(2),
  ADMITTING_SOURCE            CHAR(2),
  RAW_SITEID                  VARCHAR,
  RAW_ENC_TYPE                VARCHAR,
  RAW_DISCHARGE_DISPOSITION   VARCHAR,
  RAW_DISCHARGE_STATUS        VARCHAR,
  RAW_DRG_TYPE                VARCHAR,
  RAW_ADMITTING_SOURCE        VARCHAR
);


CREATE TABLE PCORI_CDMV3.DIAGNOSIS (
  DIAGNOSISID     VARCHAR(50) NOT NULL PRIMARY KEY,
  PATID           VARCHAR(50) NOT NULL,
  ENCOUNTERID     VARCHAR(50) NOT NULL,
  ENC_TYPE        CHAR(2),
  ADMIT_DATE      DATE,
  PROVIDERID      VARCHAR(50),
  DX              VARCHAR(18) NOT NULL,
  DX_TYPE         CHAR(2) NOT NULL,
  DX_SOURCE       CHAR(2) NOT NULL,
  PDX             VARCHAR(2),
  RAW_DX          VARCHAR,
  RAW_DX_TYPE     VARCHAR,
  RAW_DX_SOURCE   VARCHAR,
  RAW_PDX         VARCHAR
);


CREATE TABLE PCORI_CDMV3.PROCEDURES (
  PROCEDURESID    VARCHAR(50) NOT NULL PRIMARY KEY,
  PATID           VARCHAR(50) NOT NULL,
  ENCOUNTERID     VARCHAR(50) NOT NULL,
  ENC_TYPE        CHAR(2),
  ADMIT_DATE      DATE,
  PROVIDERID      VARCHAR(50),
  PX              VARCHAR(18) NOT NULL,
  PX_TYPE         CHAR(2) NOT NULL,
  PX_SOURCE       CHAR(2),
  RAW_PX          VARCHAR,
  RAW_PX_TYPE     VARCHAR
);


CREATE TABLE PCORI_CDMV3.VITAL (
  VITALID           VARCHAR(50) NOT NULL PRIMARY KEY,
  PATID             VARCHAR(50) NOT NULL,
  ENCOUNTERID       VARCHAR(50),
  MEASURE_DATE      DATE NOT NULL,
  MEASURE_TIME      VARCHAR(5),
  VITAL_SOURCE      CHAR(2) NOT NULL,
  HT                FLOAT,
  WT                FLOAT,
  DIASTOLIC         FLOAT,
  SYSTOLIC          FLOAT,
  ORIGINAL_BMI      FLOAT,
  BP_POSITION       CHAR(2),
  SMOKING           CHAR(2),
  TOBACCO           CHAR(2),
  TOBACCO_TYPE      CHAR(2),
  RAW_DIASTOLIC     VARCHAR,
  RAW_SYSTOLIC      VARCHAR,
  RAW_BP_POSITION   VARCHAR,
  RAW_SMOKING       VARCHAR,
  RAW_TOBACCO       VARCHAR,
  RAW_TOBACCO_TYPE  VARCHAR
);


CREATE TABLE PCORI_CDMV3.DISPENSING (
  DISPENSINGID    VARCHAR(50) NOT NULL PRIMARY KEY,
  PATID           VARCHAR(50) NOT NULL,
  PRESCRIBINGID   VARCHAR(50),
  DISPENSE_DATE   DATE NOT NULL,
  NDC             VARCHAR(11) NOT NULL,
  DISPENSE_SUP    INTEGER,
  DISPENSE_AMT    FLOAT,
  RAW_NDC         VARCHAR
);


CREATE TABLE PCORI_CDMV3.LAB_RESULT_CM (
  LAB_RESULT_CM_ID    VARCHAR(50) NOT NULL PRIMARY KEY,
  PATID               VARCHAR(50) NOT NULL,
  ENCOUNTERID         VARCHAR(50),
  LAB_NAME            VARCHAR(10),
  SPECIMEN_SOURCE     VARCHAR(10),
  LAB_LOINC           VARCHAR(10),
  PRIORITY            VARCHAR(2),
  RESULT_LOC          VARCHAR(2),
  LAB_PX              VARCHAR(11),
  LAB_PX_TYPE         CHAR(2),
  LAB_ORDER_DATE      DATE,
  SPECIMEN_DATE       DATE,
  SPECIMEN_TIME       CHAR(5),
  RESULT_DATE         DATE NOT NULL,
  RESULT_TIME         CHAR(5),
  RESULT_QUAL         VARCHAR(12),
  RESULT_NUM          FLOAT,
  RESULT_MODIFIER     CHAR(2),
  RESULT_UNIT         VARCHAR(11),
  NORM_RANGE_LOW      VARCHAR(10),
  NORM_MODIFIER_LOW   CHAR(2),
  NORM_RANGE_HIGH     VARCHAR(10),
  NORM_MODIFIER_HIGH  CHAR(2),
  ABN_IND             CHAR(2),
  RAW_LAB_NAME        VARCHAR(250),
  RAW_LAB_CODE        VARCHAR(250),
  RAW_PANEL           VARCHAR(250),
  RAW_RESULT          VARCHAR(250),
  RAW_UNIT            VARCHAR(250),
  RAW_ORDER_DEPT      VARCHAR(250),
  RAW_FACILITY_CODE   VARCHAR(250)
);



CREATE TABLE PCORI_CDMV3.CONDITION (
  CONDITIONID            VARCHAR(50) NOT NULL PRIMARY KEY,
  PATID                  VARCHAR(50) NOT NULL,
  ENCOUNTERID            VARCHAR(50),
  REPORT_DATE            DATE,
  RESOLVE_DATE           DATE,
  ONSET_DATE             DATE,
  CONDITION_STATUS       CHAR(2),
  CONDITION              VARCHAR(18) NOT NULL,
  CONDITION_TYPE         CHAR(2) NOT NULL,
  CONDITION_SOURCE       CHAR(2) NOT NULL,
  RAW_CONDITION_STATUS   VARCHAR,
  RAW_CONDITION          VARCHAR,
  RAW_CONDITION_TYPE     VARCHAR,
  RAW_CONDITION_SOURCE   VARCHAR
);


CREATE TABLE PCORI_CDMV3.PRO_CM (
  PRO_CM_ID         VARCHAR(50) NOT NULL PRIMARY KEY,
  PATID             VARCHAR(50) NOT NULL,
  ENCOUNTERID       VARCHAR(50),
  PRO_ITEM          VARCHAR(7) NOT NULL,
  PRO_LOINC         VARCHAR(10),
  PRO_DATE          DATE NOT NULL,
  PRO_TIME          CHAR(5),
  PRO_RESPONSE      INTEGER NOT NULL, /* NOT CERTAIN IF INTEGER OR FLOAT */
  PRO_METHOD        CHAR(2),
  PRO_MODE          CHAR(2),
  PRO_CAT           VARCHAR(2),
  RAW_PRO_CODE      VARCHAR,
  RAW_PRO_RESPONSE  VARCHAR
);


CREATE TABLE PCORI_CDMV3.PRESCRIBING (
  PRESCRIBINGID      VARCHAR(50) NOT NULL PRIMARY KEY,
  PATID              VARCHAR(50) NOT NULL,
  ENCOUNTERID        VARCHAR(50),
  RX_PROVIDERID      VARCHAR,
  RX_ORDER_DATE      DATE,
  RX_ORDER_TIME      CHAR(5),
  RX_START_DATE      DATE,
  RX_END_DATE        DATE,
  RX_QUANTITY        FLOAT,
  RX_REFILLS         FLOAT,
  RX_DAYS_SUPPLY     FLOAT,
  RX_FREQUENCY       CHAR(2),
  RX_BASIS           CHAR(2),
  RXNORM_CUI         INTEGER,
  RAW_RX_MED_NAME    VARCHAR,
  RAW_RX_FREQUENCY   VARCHAR,
  RAW_RXNORM_CUI     VARCHAR
);


CREATE TABLE PCORI_CDMV3.PCORNET_TRIAL (
  PATID                 VARCHAR(50) NOT NULL,
  TRIALID               VARCHAR(20) NOT NULL,
  PARTICIPANTID         VARCHAR NOT NULL,
  TRIAL_SITEID          VARCHAR,
  TRIAL_ENROLL_DATE     DATE,
  TRIAL_END_DATE        DATE,
  TRIAL_WITHDRAW_DATE   DATE,
  TRIAL_INVITE_CODE     VARCHAR(20),
  PRIMARY KEY ( PATID, TRIALID, PARTICIPANTID )
);



CREATE TABLE PCORI_CDMV3.DEATH (
  PATID                      VARCHAR(50) NOT NULL,
  DEATH_DATE                 DATE NOT NULL,
  DEATH_DATE_IMPUTE          VARCHAR(2),
  DEATH_SOURCE               VARCHAR(2) NOT NULL,
  DEATH_MATCH_CONFIDENCE     VARCHAR(2),
  PRIMARY KEY ( PATID, DEATH_DATE, DEATH_SOURCE  )
);



CREATE TABLE PCORI_CDMV3.DEATH_CAUSE (
  PATID                      VARCHAR(50) NOT NULL,
  DEATH_CAUSE                VARCHAR(8) NOT NULL,
  DEATH_CAUSE_CODE           CHAR(2) NOT NULL,
  DEATH_CAUSE_TYPE           VARCHAR(2) NOT NULL,
  DEATH_CAUSE_SOURCE         VARCHAR(2) NOT NULL,
  DEATH_CAUSE_CONFIDENCE     VARCHAR(2),
  PRIMARY KEY ( PATID, DEATH_CAUSE, DEATH_CAUSE_CODE,
                DEATH_CAUSE_TYPE, DEATH_CAUSE_SOURCE )
);


CREATE TABLE PCORI_CDMV3.HARVEST (
  NETWORKID                    VARCHAR(10) NOT NULL,
  NETWORK_NAME                 VARCHAR(20),
  DATAMARTID                   VARCHAR(10) NOT NULL,
  DATAMART_NAME                VARCHAR(20),
  DATAMART_PLATFORM            CHAR(2),
  CDM_VERSION                  FLOAT,
  DATAMART_CLAIMS              CHAR(2),
  DATAMART_EHR                 CHAR(2),
  BIRTH_DATE_MGMT              CHAR(2),
  ENR_START_DATE_MGMT          CHAR(2),
  ENR_END_DATE_MGMT            CHAR(2),
  ADMIT_DATE_MGMT              CHAR(2),
  DISCHARGE_DATE_MGMT          CHAR(2),
  PX_DATE_MGMT                 CHAR(2),
  RX_ORDER_DATE_MGMT           CHAR(2),
  RX_START_DATE_MGMT           CHAR(2),
  RX_END_DATE_MGMT             CHAR(2),
  DISPENSE_DATE_MGMT           CHAR(2),
  LAB_ORDER_DATE_MGMT          CHAR(2),
  SPECIMEN_DATE_MGMT           CHAR(2),
  RESULT_DATE_MGMT             CHAR(2),
  MEASURE_DATE_MGMT            CHAR(2),
  ONSET_DATE_MGMT              CHAR(2),
  REPORT_DATE_MGMT             CHAR(2),
  RESOLVE_DATE_MGMT            CHAR(2),
  PRO_DATE_MGMT                CHAR(2),
  REFRESH_DEMOGRAPHIC_DATE     DATE,
  REFRESH_ENROLLMENT_DATE      DATE,
  REFRESH_ENCOUNTER_DATE       DATE,
  REFRESH_DIAGNOSIS_DATE       DATE,
  REFRESH_PROCEDURES_DATE      DATE,
  REFRESH_VITAL_DATE           DATE,
  REFRESH_DISPENSING_DATE      DATE,
  REFRESH_LAB_RESULT_CM_DATE   DATE,
  REFRESH_CONDITION_DATE       DATE,
  REFRESH_PRO_CM_DATE          DATE,
  REFRESH_PRESCRIBING_DATE     DATE,
  REFRESH_PCORNET_TRIAL_DATE   DATE,
  REFRESH_DEATH_DATE           DATE,
  REFRESH_DEATH_CAUSE_DATE     DATE,
  PRIMARY KEY ( NETWORKID, DATAMARTID )
);


-- FOREIGN KEYS

ALTER TABLE PCORI_CDMV3.ENROLLMENT
ADD CONSTRAINT FK_ENROLLMENT_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.ENCOUNTER
ADD CONSTRAINT FK_ENCOUNTER_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.DIAGNOSIS
ADD CONSTRAINT FK_DIAGNOSIS_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.DIAGNOSIS
ADD CONSTRAINT FK_DIAGNOSIS_ENCOUNTER_ENCOUNTERID
FOREIGN KEY ( ENCOUNTERID )
REFERENCES PCORI_CDMV3.ENCOUNTER ( ENCOUNTERID );

ALTER TABLE PCORI_CDMV3.PROCEDURES
ADD CONSTRAINT FK_PROCEDURES_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.PROCEDURES
ADD CONSTRAINT FK_PROCEDURES_ENCOUNTER_ENCOUNTERID
FOREIGN KEY ( ENCOUNTERID )
REFERENCES PCORI_CDMV3.ENCOUNTER ( ENCOUNTERID );

ALTER TABLE PCORI_CDMV3.VITAL
ADD CONSTRAINT FK_VITAL_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.VITAL
ADD CONSTRAINT FK_VITAL_ENCOUNTER_ENCOUNTERID
FOREIGN KEY ( ENCOUNTERID )
REFERENCES PCORI_CDMV3.ENCOUNTER ( ENCOUNTERID );

ALTER TABLE PCORI_CDMV3.DISPENSING
ADD CONSTRAINT FK_DISPENSING_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.DISPENSING
ADD CONSTRAINT FK_DISPENSING_PRESCRIBING_PRESCRIBINGID
FOREIGN KEY ( PRESCRIBINGID )
REFERENCES PCORI_CDMV3. PRESCRIBING ( PRESCRIBINGID );

ALTER TABLE PCORI_CDMV3.LAB_RESULT_CM
ADD CONSTRAINT FK_LAB_RESULT_CM_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.LAB_RESULT_CM
ADD CONSTRAINT FK_LAB_RESULT_CM_ENCOUNTER_ENCOUNTERID
FOREIGN KEY ( ENCOUNTERID )
REFERENCES PCORI_CDMV3.ENCOUNTER ( ENCOUNTERID );

ALTER TABLE PCORI_CDMV3.CONDITION
ADD CONSTRAINT FK_CONDITION_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.CONDITION
ADD CONSTRAINT FK_CONDITION_ENCOUNTER_ENCOUNTERID
FOREIGN KEY ( ENCOUNTERID )
REFERENCES PCORI_CDMV3.ENCOUNTER ( ENCOUNTERID );

ALTER TABLE PCORI_CDMV3.PRO_CM
ADD CONSTRAINT FK_PRO_CM_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.PRO_CM
ADD CONSTRAINT FK_PRO_CM_ENCOUNTER_ENCOUNTERID
FOREIGN KEY ( ENCOUNTERID )
REFERENCES PCORI_CDMV3.ENCOUNTER ( ENCOUNTERID );

ALTER TABLE PCORI_CDMV3.PRESCRIBING
ADD CONSTRAINT FK_PRESCRIBING_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.PRESCRIBING
ADD CONSTRAINT FK_PRESCRIBING_ENCOUNTER_ENCOUNTERID
FOREIGN KEY ( ENCOUNTERID )
REFERENCES PCORI_CDMV3.ENCOUNTER ( ENCOUNTERID );

ALTER TABLE PCORI_CDMV3.PCORNET_TRIAL
ADD CONSTRAINT FK_PCORNET_TRIAL_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.DEATH
ADD CONSTRAINT FK_DEATH_DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );

ALTER TABLE PCORI_CDMV3.DEATH_CAUSE
ADD CONSTRAINT FK_DEATH_CAUSE__DEMOGRAPHIC_PATID
FOREIGN KEY ( PATID )
REFERENCES PCORI_CDMV3.DEMOGRAPHIC( PATID );
