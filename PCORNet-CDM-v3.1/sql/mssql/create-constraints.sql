USE pcori_cdmv3_1;

ALTER TABLE pcori_cdmv3_1.demographic ADD CONSTRAINT pk_demographic PRIMARY KEY (patid);
ALTER TABLE pcori_cdmv3_1.demographic ADD CONSTRAINT ck_demographic_sex CHECK (sex IN ('A', 'F', 'M', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.demographic ADD CONSTRAINT ck_sexual_orientation CHECK ( sexual_orientation IN ( 'AS', 'BI', 'GA', 'LE', 'QU', 'QS', 'ST', 'SE', 'MU', 'DC', 'NI', 'UN', 'OT' ));
ALTER TABLE pcori_cdmv3_1.demographic ADD CONSTRAINT ck_gender_identity CHECK ( gender_identity IN ( 'M', 'F', 'TM', 'TF', 'GQ', 'SE', 'MU', 'DC', 'NI', 'UN', 'OT' ));
ALTER TABLE pcori_cdmv3_1.demographic ADD CONSTRAINT ck_demographic_hispanic CHECK (hispanic IN ('Y', 'N', 'R', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.demographic ADD CONSTRAINT ck_demographic_race CHECK (race IN ('01', '02', '03', '04', '05', '06', '07', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.demographic ADD CONSTRAINT ck_demographic_biobank_flag CHECK (biobank_flag IN ('Y', 'N'));

ALTER TABLE pcori_cdmv3_1.enrollment ADD CONSTRAINT pk_enrollment PRIMARY KEY (patid, enr_start_date, enr_basis);
ALTER TABLE pcori_cdmv3_1.enrollment ADD CONSTRAINT fk_enrollment_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.enrollment ADD CONSTRAINT ck_enrollment_chart CHECK (chart IN ('Y', 'N'));
ALTER TABLE pcori_cdmv3_1.enrollment ADD CONSTRAINT ck_enrollment_enr_bases CHECK (enr_basis IN ('I', 'D', 'G', 'A', 'E'));

ALTER TABLE pcori_cdmv3_1.encounter ADD CONSTRAINT pk_encounter PRIMARY KEY (encounterid);
ALTER TABLE pcori_cdmv3_1.encounter ADD CONSTRAINT fk_encounter_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.encounter ADD CONSTRAINT ck_encounter_enc_type CHECK (enc_type IN ('AV', 'ED', 'EI', 'IP', 'IS', 'OS', 'IC', 'OA', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.encounter ADD CONSTRAINT ck_encounter_discharge_disposition CHECK (discharge_disposition IN ('A', 'E', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.encounter ADD CONSTRAINT ck_encounter_discharge_status CHECK (discharge_status IN ('AF', 'AL', 'AM', 'AW', 'EX', 'HH', 'HO', 'HS', 'IP', 'NH', 'RH', 'RS', 'SH', 'SN', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.encounter ADD CONSTRAINT ck_encounter_drg_type CHECK (drg_type IN ('01', '02', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.encounter ADD CONSTRAINT ck_encounter_admitting_source CHECK (admitting_source IN ('AF', 'AL', 'AV', 'ED', 'HH', 'HO', 'HS', 'IP', 'NH', 'RH', 'RS', 'SN', 'NI', 'UN', 'OT'));

ALTER TABLE pcori_cdmv3_1.diagnosis ADD CONSTRAINT pk_diagnosis PRIMARY KEY (diagnosisid);
ALTER TABLE pcori_cdmv3_1.diagnosis ADD CONSTRAINT fk_diagnosis_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.diagnosis ADD CONSTRAINT fk_diagnosis_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid);
ALTER TABLE pcori_cdmv3_1.diagnosis ADD CONSTRAINT ck_diagnosis_enc_type CHECK (enc_type IN ('AV', 'ED', 'EI', 'OS', 'IC', 'IP', 'IS', 'OA', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.diagnosis ADD CONSTRAINT ck_diagnosis_dx_type CHECK (dx_type IN ('09', '10', '11', 'SM', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.diagnosis ADD CONSTRAINT ck_diagnosis_dx_source CHECK (dx_source IN ('AD', 'DI', 'FI', 'IN', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.diagnosis ADD CONSTRAINT ck_diagnosis_dx_origin CHECK (dx_origin IN ('OD', 'BI', 'CL', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.diagnosis ADD CONSTRAINT ck_diagnosis_pdx CHECK (pdx IN ('P', 'S', 'X', 'NI', 'UN', 'OT'));

ALTER TABLE pcori_cdmv3_1.procedures ADD CONSTRAINT pk_procedures PRIMARY KEY (proceduresid);
ALTER TABLE pcori_cdmv3_1.procedures ADD CONSTRAINT fk_procedures_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.procedures ADD CONSTRAINT fk_procedures_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid);
ALTER TABLE pcori_cdmv3_1.procedures ADD CONSTRAINT ck_procedures_enc_type CHECK (enc_type IN ('AV', 'ED', 'EI', 'IP', 'IS', 'OS', 'IC', 'OA', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.procedures ADD CONSTRAINT ck_procedures_px_type CHECK (px_type IN ('09', '10', '11', 'CH', 'LC', 'ND', 'RE', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.procedures ADD CONSTRAINT ck_procedures_px_source CHECK (px_source IN ('OD', 'BI', 'CL', 'NI', 'UN', 'OT'));

ALTER TABLE pcori_cdmv3_1.vital ADD CONSTRAINT pk_vital PRIMARY KEY (vitalid);
ALTER TABLE pcori_cdmv3_1.vital ADD CONSTRAINT fk_vital_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.vital ADD CONSTRAINT fk_vital_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid);
ALTER TABLE pcori_cdmv3_1.vital ADD CONSTRAINT ck_vital_source CHECK (vital_source IN ('PR', 'PD', 'HC', 'HD', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.vital ADD CONSTRAINT ck_vital_bp_position CHECK (bp_position IN ('01', '02', '03', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.vital ADD CONSTRAINT ck_vital_smoking CHECK (smoking IN ('01', '02', '03', '04', '05', '06', '07', '08', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.vital ADD CONSTRAINT ck_vital_tobacco CHECK (tobacco IN ('01', '02', '03', '04', '06', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.vital ADD CONSTRAINT ck_vital_tobacco_type CHECK (tobacco_type IN ('01', '02', '03', '04', '05', 'NI', 'UN', 'OT'));

ALTER TABLE pcori_cdmv3_1.prescribing ADD CONSTRAINT pk_prescribing PRIMARY KEY (prescribingid);
ALTER TABLE pcori_cdmv3_1.prescribing ADD CONSTRAINT fk_prescribing_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.prescribing ADD CONSTRAINT fk_prescribing_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid);
ALTER TABLE pcori_cdmv3_1.prescribing ADD CONSTRAINT ck_prescribing_rx_quantity_unit CHECK (rx_quantity_unit IN ('PI', 'TA', 'VI', 'LI', 'SO', 'SU', 'OI', 'CR', 'PO', 'PA', 'IN', 'KI', 'DE', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.prescribing ADD CONSTRAINT ck_prescribing_rx_frequency CHECK (rx_frequency IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.prescribing ADD CONSTRAINT ck_prescribing_rx_basis CHECK (rx_basis IN ('01', '02', 'NI', 'UN', 'OT'));

ALTER TABLE pcori_cdmv3_1.dispensing ADD CONSTRAINT pk_dispensing PRIMARY KEY (dispensingid);
ALTER TABLE pcori_cdmv3_1.dispensing ADD CONSTRAINT fk_dispensing_patid FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.dispensing ADD CONSTRAINT fk_dispensing_prescribing FOREIGN KEY (prescribingid) REFERENCES pcori_cdmv3.prescribing (prescribingid);

ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT pk_lab_result_cm PRIMARY KEY (lab_result_cm_id);
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT fk_lab_result_cm_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT fk_lab_result_cm_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid);
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT ck_lab_result_cm_lab_name CHECK (lab_name IN ('A1C', 'CK', 'CK_MB', 'CK_MBI', 'CREATININE', 'HGB', 'LDL', 'INR', 'TROP_I', 'TROP_T_QL', 'TROP_T_QN', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT ck_lab_result_cm_specimen_source CHECK (specimen_source IN ('BLOOD', 'CSF', 'PLASMA', 'PPP', 'SERUM', 'SR_PLS', 'URINE', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT ck_lab_result_cm_priority CHECK (priority IN ('E', 'R', 'S', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT ck_lab_result_cm_result_loc CHECK (result_loc IN ('L', 'P', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT ck_lab_result_cm_lab_px_type CHECK (lab_px_type IN ('09', '10', '11', 'CH', 'LC', 'ND', 'RE', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT ck_lab_result_cm_result_qual CHECK (result_qual IN ('BORDERLINE', 'POSITIVE', 'NEGATIVE', 'UNDETERMINED', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT ck_lab_result_cm_result_modifier CHECK (result_modifier IN ('EQ', 'GE', 'GT', 'LE', 'LT', 'TX', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT ck_lab_result_cm_norm_modifier_low CHECK (norm_modifier_low IN ('EQ', 'GE', 'GT', 'NO', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT ck_lab_result_cm_norm_modifier_high CHECK (norm_modifier_high IN ('EQ', 'LE', 'LT', 'NO', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.lab_result_cm ADD CONSTRAINT ck_lab_result_cm_abn_ind CHECK (abn_ind IN ('AB', 'AH', 'AL', 'CH', 'CL', 'CR', 'IN', 'NL', 'NI', 'UN', 'OT'));

ALTER TABLE pcori_cdmv3_1.condition ADD CONSTRAINT pk_condition PRIMARY KEY (conditionid);
ALTER TABLE pcori_cdmv3_1.condition ADD CONSTRAINT fk_condition_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.condition ADD CONSTRAINT fk_condition_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid);
ALTER TABLE pcori_cdmv3_1.condition ADD CONSTRAINT ck_condition_status CHECK (condition_status IN ('AC', 'RS', 'IN', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.condition ADD CONSTRAINT ck_condition_type CHECK (condition_type IN ('09', '10', '11', 'SM', 'HP', 'AG', 'NI', 'UN', 'OT' ));
ALTER TABLE pcori_cdmv3_1.condition ADD CONSTRAINT ck_condition_source CHECK (condition_source IN ('PR', 'HC', 'RG', 'PC', 'NI', 'UN', 'OT'));

ALTER TABLE pcori_cdmv3_1.pro_cm ADD CONSTRAINT pk_pro_cm PRIMARY KEY (pro_cm_id);
ALTER TABLE pcori_cdmv3_1.pro_cm ADD CONSTRAINT fk_pro_cm_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.pro_cm ADD CONSTRAINT fk_pro_cm_encounter FOREIGN KEY (encounterid) REFERENCES pcori_cdmv3.encounter (encounterid);
ALTER TABLE pcori_cdmv3_1.pro_cm ADD CONSTRAINT ck_pro_cm_pro_item CHECK (pro_item BETWEEN 'PN_0001' AND 'PN_0021');
ALTER TABLE pcori_cdmv3_1.pro_cm ADD CONSTRAINT ck_pro_cm_pro_method CHECK (pro_method IN ('PA', 'EC', 'PH', 'IV', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.pro_cm ADD CONSTRAINT ck_pro_cm_pro_mode CHECK (pro_mode IN ('SF', 'SA', 'PR', 'PA', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.pro_cm ADD CONSTRAINT ck_pro_cm_pro_cat CHECK (pro_cat IN ('Y', 'N', 'NI', 'UN', 'OT'));

ALTER TABLE pcori_cdmv3_1.pcornet_trial ADD CONSTRAINT pk_pcornet_trial PRIMARY KEY (patid, trialid, participantid);
ALTER TABLE pcori_cdmv3_1.pcornet_trial ADD CONSTRAINT fk_pcornet_trial_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);

ALTER TABLE pcori_cdmv3_1.death ADD CONSTRAINT pk_death PRIMARY KEY (patid, death_date, death_source);
ALTER TABLE pcori_cdmv3_1.death ADD CONSTRAINT fk_death_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.death ADD CONSTRAINT ck_death_date_impute CHECK (death_date_impute IN ('B', 'D', 'M', 'N', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.death ADD CONSTRAINT ck_death_source CHECK (death_source IN ('L', 'N', 'D', 'S', 'T', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.death ADD CONSTRAINT ck_death_match_confidence CHECK (death_match_confidence IN ('E', 'F', 'P', 'NI', 'UN', 'OT'));

ALTER TABLE pcori_cdmv3_1.death_cause ADD CONSTRAINT pk_death_cause PRIMARY KEY (patid, death_cause, death_cause_code, death_cause_type, death_cause_source);
ALTER TABLE pcori_cdmv3_1.death_cause ADD CONSTRAINT fk_death_cause_demographic FOREIGN KEY (patid) REFERENCES pcori_cdmv3.demographic (patid);
ALTER TABLE pcori_cdmv3_1.death_cause ADD CONSTRAINT ck_death_cause_code CHECK (death_cause_code IN ('09', '10', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.death_cause ADD CONSTRAINT ck_death_cause_type CHECK (death_cause_type IN ('C', 'I', 'O', 'U', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.death_cause ADD CONSTRAINT ck_death_cause_source CHECK (death_cause_source IN ('L', 'N', 'D', 'S', 'T', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.death_cause ADD CONSTRAINT ck_death_cause_confidence CHECK (death_cause_confidence IN ('E', 'F', 'P', 'NI', 'UN', 'OT'));

ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT pk_harvest PRIMARY KEY (networkid, datamartid);
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_datamart_platform CHECK (datamart_platform IN ('01', '02', '03', '04', '05', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_datamart_claims CHECK (datamart_claims IN ('01', '02', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_datamart_ehr CHECK (datamart_ehr IN ('01', '02', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_birth_date_mgmt CHECK (birth_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_enr_start_date_mgmt CHECK (enr_start_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_enr_end_date_mgmt CHECK (enr_end_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_admit_date_mgmt CHECK (admit_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_discharge_date_mgmt CHECK (discharge_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_px_date_mgmt CHECK (px_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_rx_order_date_mgmt CHECK (rx_order_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_rx_start_date_mgmt CHECK (rx_start_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_rx_end_date_mgmt CHECK (rx_end_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_dispense_date_mgmt CHECK (dispense_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_lab_order_date_mgmt CHECK (lab_order_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_specimen_date_mgmt CHECK (specimen_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_result_date_mgmt CHECK (result_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_measure_date_mgmt CHECK (measure_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_onset_date_mgmt CHECK (onset_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_report_date_mgmt CHECK (report_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_resolve_date_mgmt CHECK (resolve_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
ALTER TABLE pcori_cdmv3_1.harvest ADD CONSTRAINT ck_harvest_pro_date_mgmt CHECK (pro_date_mgmt IN ('01', '02', '03', '04', 'NI', 'UN', 'OT'));
