USE pcori_cdmv3_test
GO

CREATE INDEX pcori_cdmv3.ix_encounter_patid ON pcori_cdmv3.encounter (patid)
CREATE INDEX pcori_cdmv3.ix_encounter_admit_date ON pcori_cdmv3.encounter (admit_date)
GO

CREATE INDEX pcori_cdmv3.ix_diagnosis_patid ON pcori_cdmv3.diagnosis (patid)
CREATE INDEX pcori_cdmv3.ix_diagnosis_encounterid ON pcori_cdmv3.diagnosis (encounterid)
GO

CREATE INDEX pcori_cdmv3.ix_procedures_patid ON pcori_cdmv3.procedures (patid)
CREATE INDEX pcori_cdmv3.ix_procedures_encounterid ON pcori_cdmv3.procedures (encounterid)
GO

CREATE INDEX pcori_cdmv3.ix_vital_patid ON pcori_cdmv3.vital (patid)
CREATE INDEX pcori_cdmv3.ix_vital_encounterid ON pcori_cdmv3.vital (encounterid)
GO

CREATE INDEX pcori_cdmv3.ix_prescribing_patid ON pcori_cdmv3.prescribing (patid)
CREATE INDEX pcori_cdmv3.ix_prescribing_encounterid ON pcori_cdmv3.prescribing (encounterid)
GO

CREATE INDEX pcori_cdmv3.ix_dispensing_patid ON pcori_cdmv3.dispensing (patid)
CREATE INDEX pcori_cdmv3.ix_dispensing_encounterid ON pcori_cdmv3.dispensing (prescribingid)
GO

CREATE INDEX pcori_cdmv3.ix_lab_result_cm_patid ON pcori_cdmv3.lab_result_cm (patid)
CREATE INDEX pcori_cdmv3.ix_lab_result_cm_encounterid ON pcori_cdmv3.lab_result_cm (encounterid)
GO

CREATE INDEX pcori_cdmv3.ix_condition_patid ON pcori_cdmv3.condition (patid)
CREATE INDEX pcori_cdmv3.ix_condition_encounterid ON pcori_cdmv3.condition (encounterid)
GO

CREATE INDEX pcori_cdmv3.ix_pro_cm_patid ON pcori_cdmv3.pro_cm (patid)
CREATE INDEX pcori_cdmv3.ix_pro_cm_encounterid ON pcori_cdmv3.pro_cm (encounterid)
GO
