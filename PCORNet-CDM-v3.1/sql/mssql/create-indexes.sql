USE pcori_cdmv3_1;

CREATE INDEX ix_encounter_patid ON pcori_cdmv3_1.encounter (patid);
CREATE INDEX ix_encounter_admit_date ON pcori_cdmv3_1.encounter (admit_date);

CREATE INDEX ix_diagnosis_patid ON pcori_cdmv3_1.diagnosis (patid);
CREATE INDEX ix_diagnosis_encounterid ON pcori_cdmv3_1.diagnosis (encounterid);

CREATE INDEX ix_procedures_patid ON pcori_cdmv3_1.procedures (patid);
CREATE INDEX ix_procedures_encounterid ON pcori_cdmv3_1.procedures (encounterid);

CREATE INDEX ix_vital_patid ON pcori_cdmv3_1.vital (patid);
CREATE INDEX ix_vital_encounterid ON pcori_cdmv3_1.vital (encounterid);

CREATE INDEX ix_prescribing_patid ON pcori_cdmv3_1.prescribing (patid);
CREATE INDEX ix_prescribing_encounterid ON pcori_cdmv3_1.prescribing (encounterid);

CREATE INDEX ix_dispensing_patid ON pcori_cdmv3_1.dispensing (patid);
CREATE INDEX ix_dispensing_encounterid ON pcori_cdmv3_1.dispensing (prescribingid);

CREATE INDEX ix_lab_result_cm_patid ON pcori_cdmv3_1.lab_result_cm (patid);
CREATE INDEX ix_lab_result_cm_encounterid ON pcori_cdmv3_1.lab_result_cm (encounterid);

CREATE INDEX ix_condition_patid ON pcori_cdmv3_1.condition (patid);
CREATE INDEX ix_condition_encounterid ON pcori_cdmv3_1.condition (encounterid);

CREATE INDEX ix_pro_cm_patid ON pcori_cdmv3_1.pro_cm (patid);
CREATE INDEX ix_pro_cm_encounterid ON pcori_cdmv3_1.pro_cm (encounterid);
