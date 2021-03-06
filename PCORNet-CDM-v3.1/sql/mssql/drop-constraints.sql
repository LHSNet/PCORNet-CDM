USE pcori_cdmv3_1;

ALTER TABLE pcori_cdmv3_1.enrollment DROP CONSTRAINT pk_enrollment;
ALTER TABLE pcori_cdmv3_1.enrollment DROP CONSTRAINT fk_enrollment_demographic;
ALTER TABLE pcori_cdmv3_1.enrollment DROP CONSTRAINT ck_enrollment_chart;
ALTER TABLE pcori_cdmv3_1.enrollment DROP CONSTRAINT ck_enrollment_enr_bases;

ALTER TABLE pcori_cdmv3_1.diagnosis DROP CONSTRAINT pk_diagnosis;
ALTER TABLE pcori_cdmv3_1.diagnosis DROP CONSTRAINT fk_diagnosis_demographic;
ALTER TABLE pcori_cdmv3_1.diagnosis DROP CONSTRAINT fk_diagnosis_encounter;
ALTER TABLE pcori_cdmv3_1.diagnosis DROP CONSTRAINT ck_diagnosis_enc_type;
ALTER TABLE pcori_cdmv3_1.diagnosis DROP CONSTRAINT ck_diagnosis_dx_type;
ALTER TABLE pcori_cdmv3_1.diagnosis DROP CONSTRAINT ck_diagnosis_dx_source;
ALTER TABLE pcori_cdmv3_1.diagnosis DROP CONSTRAINT ck_diagnosis_pdx;

ALTER TABLE pcori_cdmv3_1.procedures DROP CONSTRAINT pk_procedures;
ALTER TABLE pcori_cdmv3_1.procedures DROP CONSTRAINT fk_procedures_demographic;
ALTER TABLE pcori_cdmv3_1.procedures DROP CONSTRAINT fk_procedures_encounter;
ALTER TABLE pcori_cdmv3_1.procedures DROP CONSTRAINT ck_procedures_enc_type;
ALTER TABLE pcori_cdmv3_1.procedures DROP CONSTRAINT ck_procedures_px_type;
ALTER TABLE pcori_cdmv3_1.procedures DROP CONSTRAINT ck_procedures_px_source;

ALTER TABLE pcori_cdmv3_1.vital DROP CONSTRAINT pk_vital;
ALTER TABLE pcori_cdmv3_1.vital DROP CONSTRAINT fk_vital_demographic;
ALTER TABLE pcori_cdmv3_1.vital DROP CONSTRAINT fk_vital_encounter;
ALTER TABLE pcori_cdmv3_1.vital DROP CONSTRAINT ck_vital_source;
ALTER TABLE pcori_cdmv3_1.vital DROP CONSTRAINT ck_vital_bp_position;
ALTER TABLE pcori_cdmv3_1.vital DROP CONSTRAINT ck_vital_smoking;
ALTER TABLE pcori_cdmv3_1.vital DROP CONSTRAINT ck_vital_tobacco;
ALTER TABLE pcori_cdmv3_1.vital DROP CONSTRAINT ck_vital_tobacco_type;

ALTER TABLE pcori_cdmv3_1.dispensing DROP CONSTRAINT pk_dispensing;
ALTER TABLE pcori_cdmv3_1.dispensing DROP CONSTRAINT fk_dispensing_patid;
ALTER TABLE pcori_cdmv3_1.dispensing DROP CONSTRAINT fk_dispensing_prescribing;

ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT pk_lab_result_cm;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT fk_lab_result_cm_demographic;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT fk_lab_result_cm_encounter;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT ck_lab_result_cm_lab_name;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT ck_lab_result_cm_specimen_source;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT ck_lab_result_cm_priority;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT ck_lab_result_cm_result_loc;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT ck_lab_result_cm_lab_px_type;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT ck_lab_result_cm_result_qual;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT ck_lab_result_cm_result_modifier;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT ck_lab_result_cm_norm_modifier_low;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT ck_lab_result_cm_norm_modifier_high;
ALTER TABLE pcori_cdmv3_1.lab_result_cm DROP CONSTRAINT ck_lab_result_cm_abn_ind;

ALTER TABLE pcori_cdmv3_1.condition DROP CONSTRAINT pk_condition;
ALTER TABLE pcori_cdmv3_1.condition DROP CONSTRAINT fk_condition_demographic;
ALTER TABLE pcori_cdmv3_1.condition DROP CONSTRAINT fk_condition_encounter;
ALTER TABLE pcori_cdmv3_1.condition DROP CONSTRAINT ck_condition_status;
ALTER TABLE pcori_cdmv3_1.condition DROP CONSTRAINT ck_condition_type;
ALTER TABLE pcori_cdmv3_1.condition DROP CONSTRAINT ck_condition_source;

ALTER TABLE pcori_cdmv3_1.pro_cm DROP CONSTRAINT pk_pro_cm;
ALTER TABLE pcori_cdmv3_1.pro_cm DROP CONSTRAINT fk_pro_cm_demographic;
ALTER TABLE pcori_cdmv3_1.pro_cm DROP CONSTRAINT fk_pro_cm_encounter;
ALTER TABLE pcori_cdmv3_1.pro_cm DROP CONSTRAINT ck_pro_cm_pro_item;
ALTER TABLE pcori_cdmv3_1.pro_cm DROP CONSTRAINT ck_pro_cm_pro_method;
ALTER TABLE pcori_cdmv3_1.pro_cm DROP CONSTRAINT ck_pro_cm_pro_mode;
ALTER TABLE pcori_cdmv3_1.pro_cm DROP CONSTRAINT ck_pro_cm_pro_cat;

ALTER TABLE pcori_cdmv3_1.pcornet_trial DROP CONSTRAINT pk_pcornet_trial;
ALTER TABLE pcori_cdmv3_1.pcornet_trial DROP CONSTRAINT fk_pcornet_trial_demographic;

ALTER TABLE pcori_cdmv3_1.death DROP CONSTRAINT pk_death;
ALTER TABLE pcori_cdmv3_1.death DROP CONSTRAINT fk_death_demographic;
ALTER TABLE pcori_cdmv3_1.death DROP CONSTRAINT ck_death_date_impute;
ALTER TABLE pcori_cdmv3_1.death DROP CONSTRAINT ck_death_source;
ALTER TABLE pcori_cdmv3_1.death DROP CONSTRAINT ck_death_match_confidence;

ALTER TABLE pcori_cdmv3_1.death_cause DROP CONSTRAINT pk_death_cause;
ALTER TABLE pcori_cdmv3_1.death_cause DROP CONSTRAINT fk_death_cause_demographic;
ALTER TABLE pcori_cdmv3_1.death_cause DROP CONSTRAINT ck_death_cause_code;
ALTER TABLE pcori_cdmv3_1.death_cause DROP CONSTRAINT ck_death_cause_type;
ALTER TABLE pcori_cdmv3_1.death_cause DROP CONSTRAINT ck_death_cause_source;
ALTER TABLE pcori_cdmv3_1.death_cause DROP CONSTRAINT ck_death_cause_confidence;

ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT pk_harvest;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_datamart_platform;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_datamart_claims;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_datamart_ehr;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_birth_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_enr_start_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_enr_end_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_admit_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_discharge_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_px_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_rx_order_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_rx_start_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_rx_end_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_dispense_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_lab_order_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_specimen_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_result_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_measure_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_onset_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_report_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_resolve_date_mgmt;
ALTER TABLE pcori_cdmv3_1.harvest DROP CONSTRAINT ck_harvest_pro_date_mgmt;

ALTER TABLE pcori_cdmv3_1.prescribing DROP CONSTRAINT pk_prescribing;
ALTER TABLE pcori_cdmv3_1.prescribing DROP CONSTRAINT fk_prescribing_demographic;
ALTER TABLE pcori_cdmv3_1.prescribing DROP CONSTRAINT fk_prescribing_encounter;
ALTER TABLE pcori_cdmv3_1.prescribing DROP CONSTRAINT ck_prescribing_rx_frequency;
ALTER TABLE pcori_cdmv3_1.prescribing DROP CONSTRAINT ck_prescribing_rx_basis;

ALTER TABLE pcori_cdmv3_1.encounter  DROP CONSTRAINT pk_encounter;
ALTER TABLE pcori_cdmv3_1.encounter  DROP CONSTRAINT fk_encounter_demographic;
ALTER TABLE pcori_cdmv3_1.encounter  DROP CONSTRAINT ck_encounter_enc_type;
ALTER TABLE pcori_cdmv3_1.encounter  DROP CONSTRAINT ck_encounter_discharge_disposition;
ALTER TABLE pcori_cdmv3_1.encounter  DROP CONSTRAINT ck_encounter_discharge_status;
ALTER TABLE pcori_cdmv3_1.encounter  DROP CONSTRAINT ck_encounter_drg_type;
ALTER TABLE pcori_cdmv3_1.encounter  DROP CONSTRAINT ck_encounter_admitting_source;

ALTER TABLE pcori_cdmv3_1.demographic DROP CONSTRAINT pk_demographic;
ALTER TABLE pcori_cdmv3_1.demographic DROP CONSTRAINT ck_demographic_sex;
ALTER TABLE pcori_cdmv3_1.demographic DROP CONSTRAINT ck_demographic_hispanic;
ALTER TABLE pcori_cdmv3_1.demographic DROP CONSTRAINT ck_demographic_race;
ALTER TABLE pcori_cdmv3_1.demographic DROP CONSTRAINT ck_demographic_biobank_flag;
