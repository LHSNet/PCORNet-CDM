-- PCORnet Common Data Model v3.0
-- Model 2015-07-29

-- SCHEMA   : PCORI_CDMV3
-- AUTHOR   : Ehsanullah Jan
-- UPDATED  : JAN 25, 2015

-- LICENSE  : Apache License v 2.0
--            http://www.apache.org/licenses/LICENSE-2.0

CREATE SCHEMA pcori_cdmv3;
GO

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
    raw_race     VARCHAR(255),
    CONSTRAINT pk_demographic PRIMARY KEY (patid),
    CONSTRAINT ck_demographic_sex CHECK (sex IN ('A', 'F', 'M', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_demographic_hispanic CHECK (hispanic IN ('Y', 'N', 'R', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_demographic_race CHECK (race IN ('01', '02', '03', '04', '05', '06', '07', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_demographic_biobank_flag CHECK (biobank_flag IN ('Y', 'N'))
);

CREATE TABLE pcori_cdmv3.enrollment (
    patid          VARCHAR(50) NOT NULL,
    enr_start_date DATE        NOT NULL,
    enr_end_date   DATE,
    chart          CHAR(1),
    enr_basis      CHAR(1)     NOT NULL,
    CONSTRAINT pk_enrollment PRIMARY KEY (patid, enr_start_date, enr_basis),
    CONSTRAINT fk_enrollment_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT ck_enrollment_chart CHECK (chart IN ('Y', 'N')),
    CONSTRAINT ck_enrollment_enr_bases CHECK (enr_basis IN ('I', 'G', 'A', 'E'))
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
    raw_admitting_source      VARCHAR(255),
    CONSTRAINT pk_encounter PRIMARY KEY (encounterid),
    CONSTRAINT fk_encounter_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT ck_encounter_enc_type CHECK (enc_type IN ('AV', 'ED', 'EI', 'IP', 'IS', 'OA', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_encounter_discharge_disposition CHECK (discharge_disposition IN ('A', 'E', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_encounter_discharge_status CHECK (discharge_status IN ('AF', 'AL', 'AM', 'AW', 'EX', 'HH', 'HO', 'HS', 'IP', 'NH', 'RH', 'RS', 'SH', 'SN', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_encounter_drg_type CHECK (drg_type IN ('01', '02', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_encounter_admitting_source CHECK (admitting_source IN ('AF', 'AL', 'AV', 'ED', 'HH', 'HO', 'HS', 'IP', 'NH', 'RH', 'RS', 'SN', 'NI', 'UN', 'OT'))
);

CREATE INDEX ix_encounter_patid ON pcori_cdmv3.encounter (patid);
CREATE INDEX ix_encounter_admit_date ON pcori_cdmv3.encounter (admit_date);

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
    raw_pdx       VARCHAR(255),
    CONSTRAINT pk_diagnosis PRIMARY KEY (diagnosisid),
    CONSTRAINT fk_diagnosis_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT fk_diagnosis_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid),
    CONSTRAINT ck_diagnosis_enc_type CHECK (enc_type IN ('AV', 'ED', 'EI', 'IP', 'IS', 'OA', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_diagnosis_dx_type CHECK (dx_type IN ('09', '10', '11', 'SM', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_diagnosis_dx_source CHECK (dx_source IN ('AD', 'DI', 'FI', 'IN', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_diagnosis_pdx CHECK (pdx IN ('P', 'S', 'X', 'NI', 'UN', 'OT'))
);

CREATE INDEX ix_diagnosis_patid ON pcori_cdmv3.diagnosis (patid);
CREATE INDEX ix_diagnosis_encounterid ON pcori_cdmv3.diagnosis (encounterid);

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
    raw_px_type  VARCHAR(255),
    CONSTRAINT pk_procedures PRIMARY KEY (proceduresid),
    CONSTRAINT fk_procedures_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT fk_procedures_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid),
    CONSTRAINT ck_procedures_enc_type CHECK (enc_type IN ('AV', 'ED', 'EI', 'IP', 'IS', 'OA', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_procedures_px_type CHECK (px_type IN ('09', '10', '11', 'C2', 'C3', 'C4', 'H3', 'HC', 'LC', 'ND', 'RE', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_procedures_px_source CHECK (px_source IN ('OD', 'BI', 'CL', 'NI', 'UN', 'OT'))
);

CREATE INDEX ix_procedures_patid ON pcori_cdmv3.procedures (patid);
CREATE INDEX ix_procedures_encounterid ON pcori_cdmv3.procedures (encounterid);

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
    raw_tobacco_type VARCHAR(255),
    CONSTRAINT pk_vital PRIMARY KEY (vitalid),
    CONSTRAINT fk_vital_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT fk_vital_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid),
    CONSTRAINT ck_vital_source CHECK (vital_source IN ('PR', 'PD', 'HC', 'HD', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_vital_bp_position CHECK (bp_position IN ('01', '02', '03', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_vital_smoking CHECK (smoking IN ('01', '02', '03', '04', '05', '06', '07', '08', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_vital_tobacco CHECK (tobacco IN ('01', '02', '03', '04', '06', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_vital_tobacco_type CHECK (tobacco_type IN ('01', '02', '03', '04', '05', 'NI', 'UN', 'OT'))
);

CREATE INDEX ix_vital_patid ON pcori_cdmv3.vital (patid);
CREATE INDEX ix_vital_encounterid ON pcori_cdmv3.vital (encounterid);

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
    raw_rxnorm_cui   VARCHAR(255),
    CONSTRAINT pk_prescribing PRIMARY KEY (prescribingid),
    CONSTRAINT fk_prescribing_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT fk_prescribing_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid),
    CONSTRAINT fk_prescribing_rx_frequency CHECK (rx_frequency IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', 'NI', 'UN', 'OT')),
    CONSTRAINT fk_prescribing_rx_basis CHECK (rx_basis IN ('01', '02', 'NI', 'UN', 'OT'))
);

CREATE INDEX ix_prescribing_patid ON pcori_cdmv3.prescribing (patid);
CREATE INDEX ix_prescribing_encounterid ON pcori_cdmv3.prescribing (encounterid);

CREATE TABLE pcori_cdmv3.dispensing (
    dispensingid  VARCHAR(50) NOT NULL,
    patid         VARCHAR(50) NOT NULL,
    prescribingid VARCHAR(50),
    dispense_date DATE        NOT NULL,
    ndc           VARCHAR(11) NOT NULL,
    dispense_sup  INTEGER,
    dispense_amt  DECIMAL(5, 2),
    raw_ndc       VARCHAR(255),
    CONSTRAINT pk_dispensing PRIMARY KEY (dispensingid),
    CONSTRAINT fk_dispensing_patid FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT fk_dispensing_prescribing FOREIGN KEY (prescribingid) REFERENCES pcori_cdmv3.prescribing (prescribingid)
);

CREATE INDEX ix_dispensing_patid ON pcori_cdmv3.dispensing (patid);
CREATE INDEX ix_dispensing_encounterid ON pcori_cdmv3.dispensing (prescribingid);

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
    raw_facility_code  VARCHAR(255),
    CONSTRAINT pk_lab_result_cm PRIMARY KEY (lab_result_cm_id),
    CONSTRAINT fk_lab_result_cm_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT fk_lab_result_cm_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid),
    CONSTRAINT ck_lab_result_cm_lab_name CHECK (lab_name IN ('A1C', 'CK', 'CK_MB', 'CK_MBI', 'CREATININE', 'HGB', 'LDL', 'INR', 'TROP_I', 'TROP_T_QL', 'TROP_T_QN')),
    CONSTRAINT ck_lab_result_cm_specimen_source CHECK (specimen_source IN ('BLOOD', 'CSF', 'PLASMA', 'PPP', 'SERUM', 'SR_PLS', 'URINE', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_lab_result_cm_priority CHECK (priority IN ('E', 'R', 'S', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_lab_result_cm_result_loc CHECK (result_loc IN ('L', 'P', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_lab_result_cm_lab_px_type CHECK (lab_px_type IN ('09', '10', '11', 'C2', 'C3', 'C4', 'H3', 'HC', 'LC', 'ND', 'RE', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_lab_result_cm_result_qual CHECK (result_qual IN ('BORDERLINE', 'POSITIVE', 'NEGATIVE', 'UNDETERMINED', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_lab_result_cm_result_modifier CHECK (result_modifier IN ('EQ', 'GE', 'GT', 'LE', 'LT', 'TX', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_lab_result_cm_norm_modifier_low CHECK (norm_modifier_low IN ('EQ', 'GE', 'GT', 'NO', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_lab_result_cm_norm_modifier_high CHECK (norm_modifier_high IN ('EQ', 'LE', 'LT', 'NO', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_lab_result_cm_abn_ind CHECK (abn_ind IN ('AB', 'AH', 'AL', 'CH', 'CL', 'CR', 'IN', 'NL', 'NI', 'UN', 'OT'))
);

CREATE INDEX ix_lab_result_cm_patid ON pcori_cdmv3.lab_result_cm (patid);
CREATE INDEX ix_lab_result_cm_encounterid ON pcori_cdmv3.lab_result_cm (encounterid);

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
    raw_condition_source VARCHAR(255),
    CONSTRAINT pk_condition PRIMARY KEY (conditionid),
    CONSTRAINT fk_condition_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT fk_condition_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid),
    CONSTRAINT ck_condition_status CHECK (condition_status IN ('AC', 'RS', 'IN', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_condition_type CHECK (condition_type IN ('09', '10', '11', 'SM', 'HP', 'AG', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_condition_source CHECK (condition_source IN ('PR', 'HC', 'RG', 'PC', 'NI', 'UN', 'OT'))
);

CREATE INDEX ix_condition_patid ON pcori_cdmv3.condition (patid);
CREATE INDEX ix_condition_encounterid ON pcori_cdmv3.condition (encounterid);

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
    raw_pro_response VARCHAR(255),
    CONSTRAINT pk_pro_cm PRIMARY KEY (pro_cm_id),
    CONSTRAINT fk_pro_cm_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT fk_pro_cm_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid),
    CONSTRAINT ck_pro_cm_pro_item CHECK (pro_item BETWEEN 'PN_0001' AND 'PN_0021'),
    CONSTRAINT ck_pro_cm_pro_method CHECK (pro_method IN ('PA', 'EC', 'PH', 'IV', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_pro_cm_pro_mode CHECK (pro_mode IN ('SF', 'SA', 'PR', 'PA', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_pro_cm_pro_cat CHECK (pro_cat IN ('Y', 'N', 'NI', 'UN', 'OT'))
);

CREATE INDEX ix_pro_cm_patid ON pcori_cdmv3.pro_cm (patid);
CREATE INDEX ix_pro_cm_encounterid ON pcori_cdmv3.pro_cm (encounterid);

CREATE TABLE pcori_cdmv3.pcornet_trial (
    patid               VARCHAR(50) NOT NULL,
    trialid             VARCHAR(20) NOT NULL,
    participantid       VARCHAR     NOT NULL,
    trial_siteid        VARCHAR,
    trial_enroll_date   DATE,
    trial_end_date      DATE,
    trial_withdraw_date DATE,
    trial_invite_code   VARCHAR(20),
    CONSTRAINT pk_pcornet_trial PRIMARY KEY (patid, trialid, participantid),
    CONSTRAINT fk_pcornet_trial_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid)
);

CREATE TABLE pcori_cdmv3.death (
    patid                  VARCHAR(50) NOT NULL,
    death_date             DATE        NOT NULL,
    death_date_impute      VARCHAR(2),
    death_source           VARCHAR(2)  NOT NULL,
    death_match_confidence VARCHAR(2),
    CONSTRAINT pk_death PRIMARY KEY (patid, death_date, death_source),
    CONSTRAINT fk_death_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT ck_death_date_impute CHECK (death_date_impute IN ('B', 'D', 'M', 'N', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_death_source CHECK (death_source IN ('L', 'N', 'D', 'S', 'T', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_death_match_confidence CHECK (death_match_confidence IN ('E', 'F', 'P', 'NI', 'UN', 'OT'))
);

CREATE TABLE pcori_cdmv3.death_cause (
    patid                  VARCHAR(50) NOT NULL,
    death_cause            VARCHAR(8)  NOT NULL,
    death_cause_code       CHAR(2)     NOT NULL,
    death_cause_type       VARCHAR(2)  NOT NULL,
    death_cause_source     VARCHAR(2)  NOT NULL,
    death_cause_confidence VARCHAR(2),
    CONSTRAINT pk_death_cause PRIMARY KEY (patid, death_cause, death_cause_code, death_cause_type, death_cause_source),
    CONSTRAINT fk_death_cause_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid),
    CONSTRAINT ck_death_cause_code CHECK (death_cause_code IN ('09', '10', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_death_cause_type CHECK (death_cause_type IN ('C', 'I', 'O', 'U', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_death_cause_source CHECK (death_cause_source IN ('L', 'N', 'D', 'S', 'T', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_death_cause_confidence CHECK (death_cause_confidence IN ('E', 'F', 'P', 'NI', 'UN', 'OT'))
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
    refresh_death_cause_date   DATE,
    CONSTRAINT pk_harvest PRIMARY KEY (networkid, datamartid),
    CONSTRAINT ck_harvest_datamart_platform CHECK (datamart_platform IN ('01', '02', '03', '04', '05', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_datamart_claims CHECK (datamart_claims IN ('01', '02', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_datamart_ehr CHECK (datamart_ehr IN ('01', '02', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_birth_date_mgmt CHECK (birth_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_enr_start_date_mgmt CHECK (enr_start_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_enr_end_date_mgmt CHECK (enr_end_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_admit_date_mgmt CHECK (admit_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_discharge_date_mgmt CHECK (discharge_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_px_date_mgmt CHECK (px_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_rx_order_date_mgmt CHECK (rx_order_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_rx_start_date_mgmt CHECK (rx_start_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_rx_end_date_mgmt CHECK (rx_end_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_dispense_date_mgmt CHECK (dispense_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_lab_order_date_mgmt CHECK (lab_order_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_specimen_date_mgmt CHECK (specimen_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_result_date_mgmt CHECK (result_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_measure_date_mgmt CHECK (measure_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_onset_date_mgmt CHECK (onset_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_report_date_mgmt CHECK (report_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_resolve_date_mgmt CHECK (resolve_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT')),
    CONSTRAINT ck_harvest_pro_date_mgmt CHECK (pro_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'))
);
