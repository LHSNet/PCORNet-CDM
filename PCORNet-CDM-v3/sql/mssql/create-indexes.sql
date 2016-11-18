USE pcori_cdmv3;

CREATE INDEX ix_encounter_patid ON pcori_cdmv3.encounter (patid);
CREATE INDEX ix_encounter_admit_date ON pcori_cdmv3.encounter (admit_date);

CREATE INDEX ix_diagnosis_patid ON pcori_cdmv3.diagnosis (patid);
CREATE INDEX ix_diagnosis_encounterid ON pcori_cdmv3.diagnosis (encounterid);

CREATE INDEX ix_procedures_patid ON pcori_cdmv3.procedures (patid);
CREATE INDEX ix_procedures_encounterid ON pcori_cdmv3.procedures (encounterid);

CREATE INDEX ix_vital_patid ON pcori_cdmv3.vital (patid);
CREATE INDEX ix_vital_encounterid ON pcori_cdmv3.vital (encounterid);

CREATE INDEX ix_prescribing_patid ON pcori_cdmv3.prescribing (patid);
CREATE INDEX ix_prescribing_encounterid ON pcori_cdmv3.prescribing (encounterid);

CREATE INDEX ix_dispensing_patid ON pcori_cdmv3.dispensing (patid);
CREATE INDEX ix_dispensing_encounterid ON pcori_cdmv3.dispensing (prescribingid);

CREATE INDEX ix_lab_result_cm_patid ON pcori_cdmv3.lab_result_cm (patid);
CREATE INDEX ix_lab_result_cm_encounterid ON pcori_cdmv3.lab_result_cm (encounterid);

CREATE INDEX ix_condition_patid ON pcori_cdmv3.condition (patid);
CREATE INDEX ix_condition_encounterid ON pcori_cdmv3.condition (encounterid);

CREATE INDEX ix_pro_cm_patid ON pcori_cdmv3.pro_cm (patid);
CREATE INDEX ix_pro_cm_encounterid ON pcori_cdmv3.pro_cm (encounterid);
