-- PCORnet Common Data Model v3.0
-- Model 2015-07-29

-- SCHEMA   : PCORI_CDMV3
-- AUTHOR   : Ehsanullah Jan
-- UPDATED  : JAN 25, 2015

-- LICENSE  : Apache License v 2.0
--            http://www.apache.org/licenses/LICENSE-2.0

CREATE SCHEMA pcori_cdmv3;

CREATE TABLE pcori_cdmv3.demographic (
    patid        VARCHAR(50) NOT NULL,
    birth_date   DATE,
    birth_time   CHAR(5),
    sex          VARCHAR(2),
    hispanic     VARCHAR(2),
    race         CHAR(2),
    biobank_flag CHAR(1),
    raw_sex      VARCHAR(255),
    raw_hispanic VARCHAR(255),
    raw_race     VARCHAR(255)
);

CREATE TABLE pcori_cdmv3.enrollment (
    patid          VARCHAR(50) NOT NULL,
    enr_start_date DATE        NOT NULL,
    enr_end_date   DATE,
    chart          CHAR(1),
    enr_basis      CHAR(1)     NOT NULL
);

CREATE TABLE pcori_cdmv3.encounter (
    encounterid               VARCHAR(50) NOT NULL,
    patid                     VARCHAR(50) NOT NULL,
    admit_date                DATE        NOT NULL,
    admit_time                CHAR(5),
    discharge_date            DATE,
    discharge_time            CHAR(5),
    providerid                VARCHAR(50),
    facility_location         CHAR(3),
    enc_type                  CHAR(2)     NOT NULL,
    facilityid                VARCHAR(50),
    discharge_disposition     VARCHAR(2),
    discharge_status          CHAR(2),
    drg                       CHAR(3),
    drg_type                  CHAR(2),
    admitting_source          CHAR(2),
    raw_siteid                VARCHAR(255),
    raw_enc_type              VARCHAR(255),
    raw_discharge_disposition VARCHAR(255),
    raw_discharge_status      VARCHAR(255),
    raw_drg_type              VARCHAR(255),
    raw_admitting_source      VARCHAR(255)
);

CREATE TABLE pcori_cdmv3.diagnosis (
    diagnosisid   VARCHAR(50) NOT NULL,
    patid         VARCHAR(50) NOT NULL,
    encounterid   VARCHAR(50) NOT NULL,
    enc_type      CHAR(2),
    admit_date    DATE,
    providerid    VARCHAR(50),
    dx            VARCHAR(18) NOT NULL,
    dx_type       CHAR(2)     NOT NULL,
    dx_source     CHAR(2)     NOT NULL,
    pdx           VARCHAR(2),
    raw_dx        VARCHAR(255),
    raw_dx_type   VARCHAR(255),
    raw_dx_source VARCHAR(255),
    raw_pdx       VARCHAR(255)
);

CREATE TABLE pcori_cdmv3.procedures (
    proceduresid VARCHAR(50) NOT NULL,
    patid        VARCHAR(50) NOT NULL,
    encounterid  VARCHAR(50) NOT NULL,
    enc_type     CHAR(2),
    admit_date   DATE,
    providerid   VARCHAR(50),
    px_date      DATE,
    px           VARCHAR(11) NOT NULL,
    px_type      CHAR(2)     NOT NULL,
    px_source    CHAR(2),
    raw_px       VARCHAR(255),
    raw_px_type  VARCHAR(255)
);

CREATE TABLE pcori_cdmv3.vital (
    vitalid          VARCHAR(50) NOT NULL,
    patid            VARCHAR(50) NOT NULL,
    encounterid      VARCHAR(50),
    measure_date     DATE        NOT NULL,
    measure_time     CHAR(5),
    vital_source     CHAR(2)     NOT NULL,
    ht               DECIMAL(8, 2),
    wt               DECIMAL(8, 2),
    diastolic        INT,
    systolic         INT,
    original_bmi     DECIMAL(8, 2),
    bp_position      CHAR(2),
    smoking          CHAR(2),
    tobacco          CHAR(2),
    tobacco_type     CHAR(2),
    raw_diastolic    VARCHAR(255),
    raw_systolic     VARCHAR(255),
    raw_bp_position  VARCHAR(255),
    raw_smoking      VARCHAR(255),
    raw_tobacco      VARCHAR(255),
    raw_tobacco_type VARCHAR(255)
);

CREATE TABLE pcori_cdmv3.prescribing (
    prescribingid    VARCHAR(50) NOT NULL,
    patid            VARCHAR(50) NOT NULL,
    encounterid      VARCHAR(50),
    rx_providerid    VARCHAR(50),
    rx_order_date    DATE,
    rx_order_time    CHAR(5),
    rx_start_date    DATE,
    rx_end_date      DATE,
    rx_quantity      DECIMAL(8, 2),
    rx_refills       INTEGER,
    rx_days_supply   INTEGER,
    rx_frequency     CHAR(2),
    rx_basis         CHAR(2),
    rxnorm_cui       INTEGER,
    raw_rx_med_name  VARCHAR(255),
    raw_rx_frequency VARCHAR(255),
    raw_rxnorm_cui   VARCHAR(255)
);

CREATE TABLE pcori_cdmv3.dispensing (
    dispensingid  VARCHAR(50) NOT NULL,
    patid         VARCHAR(50) NOT NULL,
    prescribingid VARCHAR(50),
    dispense_date DATE        NOT NULL,
    ndc           VARCHAR(11) NOT NULL,
    dispense_sup  INTEGER,
    dispense_amt  DECIMAL(5, 2),
    raw_ndc       VARCHAR(255)
);

CREATE TABLE pcori_cdmv3.lab_result_cm (
    lab_result_cm_id   VARCHAR(50) NOT NULL,
    patid              VARCHAR(50) NOT NULL,
    encounterid        VARCHAR(50),
    lab_name           VARCHAR(10),
    specimen_source    VARCHAR(10),
    lab_loinc          VARCHAR(10),
    priority           VARCHAR(2),
    result_loc         VARCHAR(2),
    lab_px             VARCHAR(11),
    lab_px_type        CHAR(2),
    lab_order_date     DATE,
    specimen_date      DATE,
    specimen_time      CHAR(5),
    result_date        DATE        NOT NULL,
    result_time        CHAR(5),
    result_qual        VARCHAR(12),
    result_num         FLOAT,
    result_modifier    CHAR(2),
    result_unit        VARCHAR(11),
    norm_range_low     VARCHAR(10),
    norm_modifier_low  CHAR(2),
    norm_range_high    VARCHAR(10),
    norm_modifier_high CHAR(2),
    abn_ind            CHAR(2),
    raw_lab_name       VARCHAR(255),
    raw_lab_code       VARCHAR(255),
    raw_panel          VARCHAR(255),
    raw_result         VARCHAR(255),
    raw_unit           VARCHAR(255),
    raw_order_dept     VARCHAR(255),
    raw_facility_code  VARCHAR(255)
);

CREATE TABLE pcori_cdmv3.condition (
    conditionid          VARCHAR(50) NOT NULL,
    patid                VARCHAR(50) NOT NULL,
    encounterid          VARCHAR(50),
    report_date          DATE,
    resolve_date         DATE,
    onset_date           DATE,
    condition_status     CHAR(2),
    condition            VARCHAR(18) NOT NULL,
    condition_type       CHAR(2)     NOT NULL,
    condition_source     CHAR(2)     NOT NULL,
    raw_condition_status VARCHAR(255),
    raw_condition        VARCHAR(255),
    raw_condition_type   VARCHAR(255),
    raw_condition_source VARCHAR(255)
);

CREATE TABLE pcori_cdmv3.pro_cm (
    pro_cm_id        VARCHAR(50) NOT NULL,
    patid            VARCHAR(50) NOT NULL,
    encounterid      VARCHAR(50),
    pro_item         VARCHAR(7)  NOT NULL,
    pro_loinc        VARCHAR(10),
    pro_date         DATE        NOT NULL,
    pro_time         CHAR(5),
    pro_response     INTEGER     NOT NULL,
    pro_method       CHAR(2),
    pro_mode         CHAR(2),
    pro_cat          VARCHAR(2),
    raw_pro_code     VARCHAR(255),
    raw_pro_response VARCHAR(255)
);

CREATE TABLE pcori_cdmv3.pcornet_trial (
    patid               VARCHAR(50) NOT NULL,
    trialid             VARCHAR(20) NOT NULL,
    participantid       VARCHAR     NOT NULL,
    trial_siteid        VARCHAR,
    trial_enroll_date   DATE,
    trial_end_date      DATE,
    trial_withdraw_date DATE,
    trial_invite_code   VARCHAR(20)
);

CREATE TABLE pcori_cdmv3.death (
    patid                  VARCHAR(50) NOT NULL,
    death_date             DATE        NOT NULL,
    death_date_impute      VARCHAR(2),
    death_source           VARCHAR(2)  NOT NULL,
    death_match_confidence VARCHAR(2)
);

CREATE TABLE pcori_cdmv3.death_cause (
    patid                  VARCHAR(50) NOT NULL,
    death_cause            VARCHAR(8)  NOT NULL,
    death_cause_code       CHAR(2)     NOT NULL,
    death_cause_type       VARCHAR(2)  NOT NULL,
    death_cause_source     VARCHAR(2)  NOT NULL,
    death_cause_confidence VARCHAR(2)
);

CREATE TABLE pcori_cdmv3.harvest (
    networkid                  VARCHAR(10) NOT NULL,
    network_name               VARCHAR(20),
    datamartid                 VARCHAR(10) NOT NULL,
    datamart_name              VARCHAR(20),
    datamart_platform          CHAR(2),
    cdm_version                DECIMAL(5, 2),
    datamart_claims            CHAR(2),
    datamart_ehr               CHAR(2),
    birth_date_mgmt            CHAR(2),
    enr_start_date_mgmt        CHAR(2),
    enr_end_date_mgmt          CHAR(2),
    admit_date_mgmt            CHAR(2),
    discharge_date_mgmt        CHAR(2),
    px_date_mgmt               CHAR(2),
    rx_order_date_mgmt         CHAR(2),
    rx_start_date_mgmt         CHAR(2),
    rx_end_date_mgmt           CHAR(2),
    dispense_date_mgmt         CHAR(2),
    lab_order_date_mgmt        CHAR(2),
    specimen_date_mgmt         CHAR(2),
    result_date_mgmt           CHAR(2),
    measure_date_mgmt          CHAR(2),
    onset_date_mgmt            CHAR(2),
    report_date_mgmt           CHAR(2),
    resolve_date_mgmt          CHAR(2),
    pro_date_mgmt              CHAR(2),
    refresh_demographic_date   DATE,
    refresh_enrollment_date    DATE,
    refresh_encounter_date     DATE,
    refresh_diagnosis_date     DATE,
    refresh_procedures_date    DATE,
    refresh_vital_date         DATE,
    refresh_dispensing_date    DATE,
    refresh_lab_result_cm_date DATE,
    refresh_condition_date     DATE,
    refresh_pro_cm_date        DATE,
    refresh_prescribing_date   DATE,
    refresh_pcornet_trial_date DATE,
    refresh_death_date         DATE,
    refresh_death_cause_date   DATE
);
