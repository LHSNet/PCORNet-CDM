-- PCORnet Common Data Model v4.1
-- Model 2018-05-15

-- SCHEMA   : PCORI_CDMV4.1
-- AUTHORS  : Ehsanullah Jan, Jamie Estill
-- UPDATED  : MAY 18, 2018

-- LICENSE  : Apache License v 2.0
--            http://www.apache.org/licenses/LICENSE-2.0

CREATE TABLE pcori_cdmv4_1.demographic (
    patid                        VARCHAR(50) NOT NULL,
    birth_date                   DATE,
    birth_time                   CHAR(5),
    sex                          CHAR(2),
    sexual_orientation           CHAR(2),
    gender_identity              CHAR(2),
    hispanic                     CHAR(2),
    race                         CHAR(2),
    biobank_flag                 CHAR(1),
    pat_pref_language_spoken     CHAR(3),
    raw_sex                      VARCHAR(255),
    raw_sexual_orientation       VARCHAR(255),
    raw_gender_identity          VARCHAR(255),
    raw_hispanic                 VARCHAR(255),
    raw_race                     VARCHAR(255),
    raw_pat_pref_language_spoken VARCHAR(255)
);

CREATE TABLE pcori_cdmv4_1.enrollment (
    patid          VARCHAR(50) NOT NULL,
    enr_start_date DATE        NOT NULL,
    enr_end_date   DATE,
    chart          CHAR(1),
    enr_basis      CHAR(1)     NOT NULL
);

CREATE TABLE pcori_cdmv4_1.encounter (
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
    discharge_disposition     CHAR(2),
    discharge_status          CHAR(2),
    drg                       CHAR(3),
    drg_type                  CHAR(2),
    admitting_source          CHAR(2),
    payer_type_primary        CHAR(4),
    payer_type_secondary      CHAR(4),
    facility_type             VARCHAR(100),
    raw_siteid                VARCHAR(255),
    raw_enc_type              VARCHAR(255),
    raw_discharge_disposition VARCHAR(255),
    raw_discharge_status      VARCHAR(255),
    raw_drg_type              VARCHAR(255),
    raw_admitting_source      VARCHAR(255),
    raw_facility_type         VARCHAR(255),
    raw_payer_type_primary    VARCHAR(255),
    raw_payer_name_primary    VARCHAR(255),
    raw_payer_id_primary      VARCHAR(255),
    raw_payer_type_secondary  VARCHAR(255),
    raw_payer_name_secondary  VARCHAR(255),
    raw_payer_id_secondary    VARCHAR(255)
);

CREATE TABLE pcori_cdmv4_1.diagnosis (
    diagnosisid   VARCHAR(50) NOT NULL,
    patid         VARCHAR(50) NOT NULL,
    encounterid   VARCHAR(50) NOT NULL,
    enc_type      CHAR(2),
    admit_date    DATE,
    providerid    VARCHAR(50),
    dx            VARCHAR(18) NOT NULL,
    dx_type       CHAR(2)     NOT NULL,
    dx_source     CHAR(2)     NOT NULL,
    dx_origin     CHAR(2),
    pdx           CHAR(2),
    dx_poa        CHAR(2),
    raw_dx        VARCHAR(255),
    raw_dx_type   VARCHAR(255),
    raw_dx_source VARCHAR(255),
    raw_pdx       VARCHAR(255),
    raw_dx_poa    VARCHAR(255)
);

CREATE TABLE pcori_cdmv4_1.procedures (
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
    ppx          CHAR(2),
    raw_px       VARCHAR(255),
    raw_px_type  VARCHAR(255),
    raw_ppx      VARCHAR(255)
);

CREATE TABLE pcori_cdmv4_1.vital (
    vitalid          VARCHAR(50) NOT NULL,
    patid            VARCHAR(50) NOT NULL,
    encounterid      VARCHAR(50),
    measure_date     DATE        NOT NULL,
    measure_time     CHAR(5),
    vital_source     CHAR(2)     NOT NULL,
    ht               DECIMAL(15, 8),
    wt               DECIMAL(15, 8),
    diastolic        DECIMAL(15, 8),
    systolic         DECIMAL(15, 8),
    original_bmi     DECIMAL(15, 8),
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


CREATE TABLE pcori_cdmv4_1.dispensing (
    dispensingid              VARCHAR(50) NOT NULL,
    patid                     VARCHAR(50) NOT NULL,
    prescribingid             VARCHAR(50),
    dispense_date             DATE        NOT NULL,
    ndc                       VARCHAR(11) NOT NULL,
    dispense_sup              DECIMAL(15, 8),
    dispense_amt              DECIMAL(15, 8),
    dispense_dose_disp        DECIMAL(15, 8),
    dispense_dose_disp_unit   VARCHAR(50),
    dispense_route            VARCHAR(50),
    raw_ndc                   VARCHAR(255),
    raw_dispense_dose_disp    VARCHAR(255),
    raw_dispense_dose_unit    VARCHAR(255),
    raw_dispense_route        VARCHAR(255)
);

CREATE TABLE pcori_cdmv4_1.lab_result_cm (
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
    result_snomed      VARCHAR(50),
    result_num         DECIMAL(15, 8),
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

CREATE TABLE pcori_cdmv4_1.condition (
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

CREATE TABLE pcori_cdmv4_1.pro_cm (
    pro_cm_id                      VARCHAR(50)    NOT NULL,
    patid                          VARCHAR(50)    NOT NULL,
    encounterid                    VARCHAR(50),
    pro_date                       DATE           NOT NULL,
    pro_time                       CHAR(5),
    pro_type                       CHAR(2),
    pro_item_name                  VARCHAR(20),
    pro_item_loinc                 VARCHAR(10),
    pro_response_text              VARCHAR(255),  
    pro_response_num               DECIMAL(15, 8),
    pro_method                     CHAR(2),
    pro_mode                       CHAR(2),
    pro_cat                        VARCHAR(2),
    cha                            VARCHAR(10),
    pro_measure_name               VARCHAR(100),
    pro_measure_seq                VARCHAR(10),
    pro_measure_score              DECIMAL(15, 8),
    pro_measure_theta              DECIMAL(15, 8),
    pro_measure_scaled_tscore      DECIMAL(15, 8),
    pro_measure_standard_error     DECIMAL(15, 8),
    pro_measure_count_scored       DECIMAL(15, 8),
    pro_measure_loinc              CHAR(10),
    pro_measure_version            VARCHAR(10),
    pro_item_fullname              VARCHAR(255),
    pro_item_text                  VARCHAR(255),
    pro_measure_fullname           VARCHAR(255)
);


CREATE TABLE pcori_cdmv4_1.prescribing (
    prescribingid            VARCHAR(50) NOT NULL,
    patid                    VARCHAR(50) NOT NULL,
    encounterid              VARCHAR(50),
    rx_providerid            VARCHAR(50),
    rx_order_date            DATE,
    rx_order_time            CHAR(5),
    rx_start_date            DATE,
    rx_end_date              DATE,
    rx_dose_ordered          DECIMAL(15, 8),
    rx_dose_ordered_unit     VARCHAR(50),
    rx_quantity              DECIMAL(15, 8),
    rx_dose_form             VARCHAR(50),
    rx_refills               DECIMAL(15, 8),
    rx_days_supply           DECIMAL(15, 8),
    rx_frequency             CHAR(2),
    rx_prn_flag              CHAR(1),
    rx_route                 VARCHAR(50),
    rx_basis                 CHAR(2),
    rxnorm_cui               CHAR(8),
    rx_source                CHAR(2),
    rx_dispense_as_written   CHAR(2),
    raw_rx_med_name          VARCHAR(255),
    raw_rx_frequency         VARCHAR(255),
    raw_rxnorm_cui           VARCHAR(255),
    raw_rx_quantity          VARCHAR(255),
    raw_rx_ndc               VARCHAR(255),
    raw_rx_dose_ordered      VARCHAR(255),
    raw_rx_dose_ordered_unit VARCHAR(255),
    raw_rx_route             VARCHAR(255),
    raw_rx_refills           VARCHAR(255)
);

CREATE TABLE pcori_cdmv4_1.pcornet_trial (
    patid               VARCHAR(50) NOT NULL,
    trialid             VARCHAR(20) NOT NULL,
    participantid       VARCHAR(50) NOT NULL,
    trial_siteid        VARCHAR(50),
    trial_enroll_date   DATE,
    trial_end_date      DATE,
    trial_withdraw_date DATE,
    trial_invite_code   VARCHAR(20)
);

CREATE TABLE pcori_cdmv4_1.death (
    patid                  VARCHAR(50) NOT NULL,
    death_date             DATE,
    death_date_impute      CHAR(2),
    death_source           CHAR(2)  NOT NULL,
    death_match_confidence CHAR(2)
);

CREATE TABLE pcori_cdmv4_1.death_cause (
    patid                  VARCHAR(50) NOT NULL,
    death_cause            VARCHAR(8)  NOT NULL,
    death_cause_code       CHAR(2)     NOT NULL,
    death_cause_type       CHAR(2)     NOT NULL,
    death_cause_source     CHAR(2)     NOT NULL,
    death_cause_confidence CHAR(2)
);

CREATE TABLE pcori_cdmv4_1.med_admin (
    medadminid                      VARCHAR(50) NOT NULL,
    patid                           VARCHAR(50) NOT NULL,
    encounterid                     VARCHAR(50),
    prescribingid                   VARCHAR(50),
    medadmin_providerid             VARCHAR(50),
    medadmin_start_date             DATE        NOT NULL,
    medadmin_start_time             CHAR(5),
    medadmin_stop_date              DATE,
    medadmin_stop_time              CHAR(5),
    medadmin_type                   CHAR(5),
    medadmin_code                   VARCHAR(50),
    medadmin_dose_admin             DECIMAL(15, 8),
    medadmin_dose_admin_unit        VARCHAR(50),
    medadmin_route                  VARCHAR(50),
    medadmin_source                 CHAR(2),
    raw_medadmin_med_name           VARCHAR(255),
    raw_medadmin_code               VARCHAR(255),
    raw_medadmin_dose_admin         VARCHAR(255),
    raw_medadmin_dose_admin_unit    VARCHAR(255),
    raw_medadmin_route              VARCHAR(255)
);


CREATE TABLE pcori_cdmv4_1.provider (
    providerid                        VARCHAR(50) NOT NULL,
    provider_sex                      CHAR(2),
    provider_specialty_primary        CHAR(10),
    provider_npi                      DECIMAL(15, 8),
    provider_npi_flag                 CHAR(1),
    raw_provider_specialty_primary    VARCHAR(255)
);

CREATE TABLE pcori_cdmv4_1.obs_clin (
    obsclinid                VARCHAR(50) NOT NULL,
    patid                    VARCHAR(50) NOT NULL,
    encounterid              VARCHAR(50),
    obsclin_providerid       VARCHAR(50),
    obsclin_date             DATE        NOT NULL,
    obsclin_time             CHAR(5),
    obsclin_type             CHAR(2),
    obsclin_code             VARCHAR(50),
    obsclin_result_qual      VARCHAR(50),
    obsclin_result_text      VARCHAR(50),
    obsclin_result_snomed    VARCHAR(50),
    obsclin_result_num       DECIMAL(15, 8),
    obsclin_result_modifier  CHAR(2),
    obsclin_result_unit      VARCHAR(50),
    raw_obsclin_name         VARCHAR(255),
    raw_obsclin_code         VARCHAR(255),
    raw_obsclin_type         VARCHAR(255),
    raw_obsclin_result       VARCHAR(255),
    raw_obsclin_modifier     VARCHAR(255),
    raw_obsclin_unit         VARCHAR(255)
);


CREATE TABLE pcori_cdmv4_1.obs_gen (
    obsgenid                 VARCHAR(50) NOT NULL,
    patid                    VARCHAR(50) NOT NULL,
    encounterid              VARCHAR(50),
    obsgen_providerid        VARCHAR(50),
    obsgen_date              DATE        NOT NULL,
    obsgen_time              CHAR(5),
    obsgen_type              VARCHAR(30),
    obsgen_code              VARCHAR(50),
    obsgen_result_qual       VARCHAR(12),
    obsgen_result_text       VARCHAR(50),
    obsgen_result_num        DECIMAL(15, 8),
    obsgen_result_modifier   CHAR(2),
    obsgen_result_unit       VARCHAR(50),
    obsgen_table_modified    CHAR(3),
    obsgen_id_modified       VARCHAR(50),
    raw_obsgen_name          VARCHAR(255),
    raw_obsgen_code          VARCHAR(255),
    raw_obsgen_type          VARCHAR(255),
    raw_obsgen_result        VARCHAR(255),
    raw_obsgen_unit          VARCHAR(255)
);


CREATE TABLE pcori_cdmv4_1.harvest (
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
    death_date_mgmt            CHAR(2),
    medadmin_start_date_mgmt   CHAR(2),
    medadmin_stop_date_mgmt    CHAR(2),
    obsclin_date_mgmt          CHAR(2),
    obsgen_date_mgmt           CHAR(2),
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
    refresh_med_admin_date     DATE,
    refresh_obs_clin_date      DATE,
    refresh_provider_date      DATE,
    refresh_obs_gen_date       DATE
);
