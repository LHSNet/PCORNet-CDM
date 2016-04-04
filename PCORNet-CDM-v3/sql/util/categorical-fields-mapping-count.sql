--> demographic
DECLARE @demographic_count DECIMAL = (SELECT count(*)
                                      FROM pcori_cdmv3_test.pcori_cdmv3.demographic);
SELECT
    d.sex, d.raw_sex, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @demographic_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.demographic d
GROUP BY d.sex, d.raw_sex
ORDER BY d.sex, d.raw_sex

SELECT
    d.hispanic, d.raw_hispanic, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @demographic_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.demographic d
GROUP BY d.hispanic, d.raw_hispanic
ORDER BY d.hispanic, d.raw_hispanic

SELECT
    d.race, d.raw_race, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @demographic_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.demographic d
GROUP BY d.race, d.raw_race
ORDER BY d.race, d.raw_race

--> encounter
DECLARE @encounter_count DECIMAL = (SELECT count(*)
                                    FROM pcori_cdmv3_test.pcori_cdmv3.encounter)

SELECT
    e.enc_type, e.raw_enc_type, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @encounter_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.encounter e
GROUP BY e.enc_type, e.raw_enc_type
ORDER BY e.enc_type, e.raw_enc_type

SELECT
    e.discharge_disposition, e.raw_discharge_disposition, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @encounter_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.encounter e
GROUP BY e.discharge_disposition, e.raw_discharge_disposition
ORDER BY e.discharge_disposition, e.raw_discharge_disposition

SELECT
    e.discharge_status, e.raw_discharge_status, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @encounter_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.encounter e
GROUP BY e.discharge_status, e.raw_discharge_status
ORDER BY e.discharge_status, e.raw_discharge_status

SELECT
    e.drg_type, e.raw_drg_type, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @encounter_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.encounter e
GROUP BY e.drg_type, e.raw_drg_type
ORDER BY e.drg_type, e.raw_drg_type

SELECT
    e.admitting_source, e.raw_admitting_source, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @encounter_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.encounter e
GROUP BY e.admitting_source, e.raw_admitting_source
ORDER BY e.admitting_source, e.raw_admitting_source

--> diagnosis
DECLARE @diagnosis_count DECIMAL = (SELECT count(*)
                                    FROM pcori_cdmv3_test.pcori_cdmv3.diagnosis)

SELECT
    d.dx_type, d.raw_dx_type, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @diagnosis_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.diagnosis d
GROUP BY d.dx_type, d.raw_dx_type
ORDER BY d.dx_type, d.raw_dx_type

SELECT
    d.dx_source, d.raw_dx_source, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @diagnosis_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.diagnosis d
GROUP BY d.dx_source, d.raw_dx_source
ORDER BY d.dx_source, d.raw_dx_source

SELECT
    d.pdx, d.raw_pdx, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @diagnosis_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.diagnosis d
GROUP BY d.pdx, d.raw_pdx
ORDER BY d.pdx, d.raw_pdx

--> vital
DECLARE @vital_count DECIMAL = (SELECT count(*)
                                FROM pcori_cdmv3_test.pcori_cdmv3.vital)

SELECT
    d.bp_position, d.raw_bp_position, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @vital_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.vital d
GROUP BY d.bp_position, d.raw_bp_position
ORDER BY d.bp_position, d.raw_bp_position

SELECT
    d.smoking, d.raw_smoking, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @vital_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.vital d
GROUP BY d.smoking, d.raw_smoking
ORDER BY d.smoking, d.raw_smoking

SELECT
    d.tobacco, d.raw_tobacco, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @vital_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.vital d
GROUP BY d.tobacco, d.raw_tobacco
ORDER BY d.tobacco, d.raw_tobacco

SELECT
    d.tobacco_type, d.raw_tobacco_type, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @vital_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.vital d
GROUP BY d.tobacco_type, d.raw_tobacco_type
ORDER BY d.tobacco_type, d.raw_tobacco_type

--> condition
DECLARE @condition_count DECIMAL = (SELECT count(*)
                                    FROM pcori_cdmv3_test.pcori_cdmv3.condition)

SELECT
    c.condition, c.raw_condition, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @condition_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.condition c
GROUP BY c.condition, c.raw_condition
ORDER BY c.condition, c.raw_condition

SELECT
    c.condition_status, c.raw_condition_status, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @condition_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.condition c
GROUP BY c.condition_status, c.raw_condition_status
ORDER BY c.condition_status, c.raw_condition_status

SELECT
    c.condition_type, c.raw_condition_type, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @condition_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.condition c
GROUP BY c.condition_type, c.raw_condition_type
ORDER BY c.condition_type, c.raw_condition_type

SELECT
    c.condition_source, c.raw_condition_source, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @condition_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.condition c
GROUP BY c.condition_source, c.raw_condition_source
ORDER BY c.condition_source, c.raw_condition_source

--> lab_result_cm
DECLARE @lab_result_cm_count DECIMAL = (SELECT count(*)
                                        FROM pcori_cdmv3_test.pcori_cdmv3.lab_result_cm)

SELECT
    lr.lab_name, lr.raw_lab_name, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @lab_result_cm_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.lab_result_cm lr
GROUP BY lr.lab_name, lr.raw_lab_name
ORDER BY lr.lab_name, lr.raw_lab_name

SELECT
    lr.result_unit, lr.raw_unit, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @lab_result_cm_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.lab_result_cm lr
GROUP BY lr.result_unit, lr.raw_unit
ORDER BY lr.result_unit, lr.raw_unit

--> prescribing
DECLARE @prescribing_count DECIMAL = (SELECT count(*)
                                      FROM pcori_cdmv3_test.pcori_cdmv3.prescribing)

SELECT
    p.rx_frequency, p.raw_rx_frequency, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @prescribing_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.prescribing p
GROUP BY p.rx_frequency, p.raw_rx_frequency
ORDER BY p.rx_frequency, p.raw_rx_frequency

SELECT
    p.rxnorm_cui, p.raw_rxnorm_cui, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @prescribing_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.prescribing p
GROUP BY p.rxnorm_cui, p.raw_rxnorm_cui
ORDER BY p.rxnorm_cui, p.raw_rxnorm_cui

--> dispensing
DECLARE @dispensing_count DECIMAL = (SELECT count(*)
                                     FROM pcori_cdmv3_test.pcori_cdmv3.prescribing)

SELECT
    d.ndc, d.raw_ndc, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @dispensing_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.dispensing d
GROUP BY d.ndc, d.raw_ndc
ORDER BY d.ndc, d.raw_ndc

--> procedures
DECLARE @procedures_count DECIMAL = (SELECT count(*)
                                     FROM pcori_cdmv3_test.pcori_cdmv3.prescribing)

SELECT
    p.px, p.raw_px, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @procedures_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.procedures p
GROUP BY p.px, p.raw_px
ORDER BY p.px, p.raw_px

SELECT
    p.px_type, p.raw_px_type, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @procedures_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.procedures p
GROUP BY p.px_type, p.raw_px_type
ORDER BY p.px_type, p.raw_px_type

--> procedures
DECLARE @pro_cm_count DECIMAL = (SELECT count(*)
                                 FROM pcori_cdmv3_test.pcori_cdmv3.pro_cm)

SELECT
    p.pro_response, p.raw_pro_response, count(*),
    format(count(*), '###,###,###') '#', format(count(*) / @pro_cm_count, 'p') '%'
FROM pcori_cdmv3_test.pcori_cdmv3.pro_cm p
GROUP BY p.pro_response, p.raw_pro_response
ORDER BY p.pro_response, p.raw_pro_response
