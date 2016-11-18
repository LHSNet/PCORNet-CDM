USE pcori_cdmv3;

DROP INDEX pcori_cdmv3.ix_encounter_patid;
DROP INDEX pcori_cdmv3.ix_encounter_admit_date;

DROP INDEX pcori_cdmv3.ix_diagnosis_patid;
DROP INDEX pcori_cdmv3.ix_diagnosis_encounterid;

DROP INDEX pcori_cdmv3.ix_procedures_patid;
DROP INDEX pcori_cdmv3.ix_procedures_encounterid;

DROP INDEX pcori_cdmv3.ix_vital_patid;
DROP INDEX pcori_cdmv3.ix_vital_encounterid;

DROP INDEX pcori_cdmv3.ix_prescribing_patid;
DROP INDEX pcori_cdmv3.ix_prescribing_encounterid;

DROP INDEX pcori_cdmv3.ix_dispensing_patid;
DROP INDEX pcori_cdmv3.ix_dispensing_encounterid;

DROP INDEX pcori_cdmv3.ix_lab_result_cm_patid;
DROP INDEX pcori_cdmv3.ix_lab_result_cm_encounterid;

DROP INDEX pcori_cdmv3.ix_condition_patid;
DROP INDEX pcori_cdmv3.ix_condition_encounterid;

DROP INDEX pcori_cdmv3.ix_pro_cm_patid;
DROP INDEX pcori_cdmv3.ix_pro_cm_encounterid;
