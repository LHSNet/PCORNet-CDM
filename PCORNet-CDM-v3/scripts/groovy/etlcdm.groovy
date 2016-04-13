#! /usr/bin/env groovy
import groovy.sql.Sql
import groovy.text.SimpleTemplateEngine
import org.slf4j.LoggerFactory
import org.slf4j.MDC

import java.time.LocalDate

@GrabConfig(systemClassLoader = true)
@Grapes([
        @Grab('net.sourceforge.jtds:jtds:1.3.1'),
        @Grab('org.slf4j:slf4j-api:1.7.19'),
        @Grab('ch.qos.logback:logback-classic:1.1.6'),
        @Grab('commons-cli:commons-cli:1.3.1')
])

CliBuilder cli = cli()
def options = cli.parse(args)
if (!options) {
    return
}

ETL etl = etl(options)
etl.withCloseable {it.process()}

// @formatter:off
CliBuilder cli() {
    def cli = new CliBuilder(usage: "etlcdm.groovy -n <server> [-t <port>] -d <database> -u <username> -p <password> -j <job> -s <startDate> -l <limitDate> [-i <interval>] [-e <errorThreshold>]")
    cli.with {
        n longOpt: 'server',         required: true,  args: 1, argName: 'name', 'Database server'
        t longOpt: 'port',           required: false, args: 1, argName: 'n',    'Database port'
        d longOpt: 'database',       required: true,  args: 1, argName: 'name', 'Target database'
        u longOpt: 'username',       required: true,  args: 1, argName: 'name', 'Database username'
        p longOpt: 'password',       required: true,  args: 1, argName: 'file', 'File with database password'
        j longOpt: 'job',            required: true,  args: 1, argName: 'name', 'Target table <demographic, encounter, death, enrollment, condition, diagnosis, procedures, vital, prescribing, lab_result_cm>'
        s longOpt: 'startDate',      required: true,  args: 1, argName: 'date', 'Start date for ETL load'
        l longOpt: 'limitDate',      required: true,  args: 1, argName: 'date', 'Limit date for ETL load'
        i longOpt: 'interval',       required: false, args: 1, argName: 'n',    'Max no. of rows to ETL in one go'
        e longOpt: 'errorThreshold', required: false, args: 1, argName: 'n',    'Max no. of errors before ETL is aborted'
        it
    }
}
// @formatter:on

ETL etl(OptionAccessor options) {
    [server        : options.server,
     port          : options.port ? Integer.valueOf(options.port) : 1433,
     database      : options.database,
     username      : options.username,
     password      : new File(options.password).text,
     job           : options.job,
     startDate     : LocalDate.parse(options.startDate),
     limitDate     : LocalDate.parse(options.limitDate),
     interval      : options.interval ? Integer.valueOf(options.interval) : 1,
     errorThreshold: options.errorThreshold ? Integer.valueOf(options.errorThreshold) : 3]
}

class ETL implements Closeable {
    private final static logger = LoggerFactory.getLogger(ETL)
    private final static Map<String, String> jobs = ['demographic'  : SQL_DEMOGRAPHIC,
                                                     'encounter'    : SQL_ENCOUNTER,
                                                     'death'        : SQL_DEATH,
                                                     'enrollment'   : SQL_ENROLLMENT,
                                                     'condition'    : SQL_CONDITION,
                                                     'diagnosis'    : SQL_DIAGNOSIS,
                                                     'procedures'   : SQL_PROCEDURES,
                                                     'vital'        : SQL_VITAL,
                                                     'prescribing'  : SQL_PRESCRIBING,
                                                     'lab_result_cm': SQL_LAB_RESULT_CM].asImmutable()

    String server
    int port
    String database
    String username
    String password

    String job
    LocalDate startDate
    LocalDate limitDate
    int interval
    int errorThreshold

    private Sql sql

    void process() {
        if (!jobs[job]) {
            logger.error("job not found: {}", job)
            return
        }

        sql = Sql.newInstance([driver  : "net.sourceforge.jtds.jdbc.Driver",
                               url     : "jdbc:jtds:sqlserver://$server:$port",
                               user    : username,
                               password: password])

        mdc("job", job, {
            logger.info("initiating etl job for period [{} - {}]", startDate, limitDate)
            long rowsAffected = 0
            long duration = benchmark({
                String statement = mkString(jobs[job], ['database': database])
                PeriodIterator periods = [startDate, limitDate, interval]
                periods.each {period ->
                    try {
                        int n = sql.executeUpdate(period, statement)
                        logger.info("processed period [$period.startDate - $period.endDate] - $n rows affected")
                        rowsAffected += n
                    } catch (Exception e) {
                        logger.warn("error processing period [$period.startDate - $period.endDate]: ", e)
                    }
                }
            })
            logger.info("etl job completed in $duration ms - $rowsAffected rows affected")
        })
    }

    void close() {
        if (sql != null) {
            sql.close()
        }
    }

    private static String mkString(String template, Map<String, String> binding) {
        SimpleTemplateEngine engine = new SimpleTemplateEngine()
        engine.createTemplate(template)
              .make(binding)
              .toString()
    }

    private static long benchmark(Closure closure) {
        long timestamp = System.currentTimeMillis()
        closure.call()
        System.currentTimeMillis() - timestamp
    }

    private static void mdc(String key, String value, Closure closure) {
        try {
            MDC.put(key, value);
            closure.call()
        } finally {
            MDC.remove(key)
        }
    }

    private static class PeriodIterator implements Iterator<Map<String, String>> {
        private LocalDate startDate
        private final LocalDate limitDate
        private final int interval

        PeriodIterator(LocalDate startDate, LocalDate limitDate, int interval) {
            this.startDate = startDate
            this.limitDate = limitDate
            this.interval = interval
        }

        @Override
        boolean hasNext() {
            !startDate.isAfter(limitDate)
        }

        @Override
        Map<String, String> next() {
            if (!hasNext()) {
                throw new NoSuchElementException()
            }

            def period = nextPeriod()
            startDate = period[0].plusDays(1)
            period[1]
        }

        private Tuple nextPeriod() {
            LocalDate endDate = startDate.plusDays(interval)
            if (endDate.isAfter(limitDate)) {
                endDate = limitDate
            }

            [endDate, ["startDate": startDate.toString(),
                       "endDate"  : endDate.toString()]]
        }
    }

    private static final String SQL_DEMOGRAPHIC = """
USE <%=database%>

INSERT INTO pcori_cdmv3.demographic (
    patid,
    birth_date,
    birth_time,
    sex,
    hispanic,
    race,
    biobank_flag,
    raw_sex,
    raw_hispanic,
    raw_race
)
    SELECT DISTINCT
        demo.patid,
        demo.birth_date,
        demo.birth_time,
        demo.sex,
        demo.hispanic,
        demo.race,
        demo.biobank_flag,
        demo.raw_sex,
        demo.raw_hispanic,
        demo.raw_race
    FROM rdw_views.pcornetcdmv3.demographic demo
        JOIN rdw_views.pcornetcdmv3.encounter enc ON enc.patid = demo.patid
    WHERE enc.admit_date BETWEEN :startDate AND :endDate
          AND NOT EXISTS(SELECT *
                         FROM pcori_cdmv3.demographic d (NOLOCK)
                         WHERE d.patid = demo.patid)"""

    private static final String SQL_ENCOUNTER = """
USE <%=database%>

INSERT INTO pcori_cdmv3.encounter (
    encounterid,
    patid,
    admit_date,
    admit_time,
    discharge_date,
    discharge_time,
    providerid,
    facility_location,
    enc_type,
    facilityid,
    discharge_disposition,
    discharge_status,
    drg,
    drg_type,
    admitting_source,
    raw_siteid,
    raw_enc_type,
    raw_discharge_disposition,
    raw_discharge_status,
    raw_drg_type,
    raw_admitting_source
)
    SELECT
        e.encounterid,
        e.patid,
        e.admit_date,
        e.admit_time,
        e.discharge_date,
        e.discharge_time,
        e.providerid,
        e.facility_location,
        e.enc_type,
        e.facilityid,
        e.discharge_disposition,
        e.discharge_status,
        e.drg,
        e.drg_type,
        e.admitting_source,
        e.raw_siteid,
        e.raw_enc_type,
        e.raw_discharge_disposition,
        e.raw_discharge_status,
        e.raw_drg_type,
        e.raw_admitting_source
    FROM pcori_cdmv3.demographic d
        JOIN rdw_views.pcornetcdmv3.encounter e ON e.patid = d.patid
    WHERE e.admit_date BETWEEN :startDate AND :endDate
          AND NOT EXISTS(SELECT *
                         FROM pcori_cdmv3.encounter enc (NOLOCK)
                         WHERE enc.encounterid = e.encounterid)"""

    private static final String SQL_DEATH = """
USE <%=database%>

INSERT INTO pcori_cdmv3.death (
    patid,
    death_date,
    death_date_impute,
    death_source,
    death_match_confidence
)
    SELECT
        DISTINCT
        dt.patid,
        dt.death_date,
        dt.death_date_impute,
        dt.death_source,
        dt.death_match_confidence
    FROM rdw_views.pcornetcdmv3.death dt
        JOIN pcori_cdmv3.encounter enc ON enc.patid = dt.patid
    WHERE enc.admit_date BETWEEN :startDate AND :endDate
          AND NOT EXISTS(SELECT *
                         FROM pcori_cdmv3.death d (NOLOCK)
                         WHERE d.patid = dt.patid)"""

    private static final String SQL_ENROLLMENT = """
USE <%=database%>

INSERT INTO pcori_cdmv3.enrollment (
    patid,
    enr_start_date,
    enr_end_date,
    chart,
    enr_basis
)
    SELECT DISTINCT
        enr.patid,
        enr.enr_start_date,
        enr.enr_end_date,
        enr.chart,
        enr.enr_basis
    FROM pcori_cdmv3.encounter enc
        JOIN rdw_views.pcornetcdmv3.enrollment enr ON enr.patid = enc.patid
    WHERE enc.admit_date BETWEEN :startDate AND :endDate
          AND NOT EXISTS(SELECT *
                         FROM pcori_cdmv3.enrollment e (NOLOCK)
                         WHERE e.patid = enr.patid
                               AND e.enr_start_date = enr.enr_start_date
                               AND e.enr_basis = enr.enr_basis)"""

    private static final String SQL_CONDITION = """
USE <%=database%>

INSERT INTO pcori_cdmv3.condition (
    conditionid,
    patid,
    encounterid,
    report_date,
    resolve_date,
    onset_date,
    condition_status,
    condition,
    condition_type,
    condition_source,
    raw_condition_status,
    raw_condition,
    raw_condition_type,
    raw_condition_source
)
    SELECT
        c.conditionid,
        c.patid,
        c.encounterid,
        c.report_date,
        c.resolve_date,
        c.onset_date,
        c.condition_status,
        c.condition,
        c.condition_type,
        c.condition_source,
        c.raw_condition_status,
        c.raw_condition,
        c.raw_condition_type,
        c.raw_condition_source
    FROM pcori_cdmv3.encounter e
        JOIN rdw_views.pcornetcdmv3.condition c ON c.encounterid = e.encounterid
                                                   AND c.patid = e.patid
    WHERE e.admit_date BETWEEN :startDate AND :endDate
          AND NOT EXISTS(SELECT *
                         FROM pcori_cdmv3.condition cond (NOLOCK)
                         WHERE cond.patid = c.patid
                               AND cond.encounterid = c.encounterid
                               AND cond.conditionid = c.conditionid)"""

    private static final String SQL_DIAGNOSIS = """
USE <%=database%>

INSERT INTO pcori_cdmv3.diagnosis (
    diagnosisid,
    patid,
    encounterid,
    enc_type,
    admit_date,
    providerid,
    dx,
    dx_type,
    dx_source,
    pdx,
    raw_dx,
    raw_dx_type,
    raw_dx_source,
    raw_pdx
)
    SELECT
        d.diagnosisid,
        d.patid,
        d.encounterid,
        d.enc_type,
        d.admit_date,
        d.providerid,
        LEFT(d.dx, 18),
        LEFT(d.dx_type, 2),
        LEFT(d.dx_source, 2),
        LEFT(d.pdx, 2),
        LEFT(d.raw_dx, 255),
        LEFT(d.raw_dx_type, 255),
        LEFT(d.raw_dx_source, 255),
        LEFT(d.raw_pdx, 255)
    FROM pcori_cdmv3.encounter enc
        JOIN rdw_views.pcornetcdmv3.diagnosis d ON d.encounterid = enc.encounterid
                                                   AND d.patid = enc.patid
    WHERE enc.admit_date BETWEEN :startDate AND :endDate
          AND NOT EXISTS(SELECT *
                         FROM pcori_cdmv3.diagnosis diag (NOLOCK)
                         WHERE diag.diagnosisid = d.diagnosisid)"""

    private static final String SQL_PROCEDURES = """
USE <%=database%>

INSERT INTO pcori_cdmv3.procedures (
    proceduresid,
    patid,
    encounterid,
    enc_type,
    admit_date,
    providerid,
    px_date,
    px,
    px_type,
    px_source,
    raw_px,
    raw_px_type
)
    SELECT
        pr.proceduresid,
        pr.patid,
        pr.encounterid,
        pr.enc_type,
        pr.admit_date,
        pr.providerid,
        pr.px_date,
        pr.px,
        pr.px_type,
        pr.px_source,
        pr.raw_px,
        pr.raw_px_type
    FROM pcori_cdmv3.encounter e
        JOIN rdw_views.pcornetcdmv3.procedures pr ON pr.encounterid = e.encounterid
                                                     AND pr.patid = e.patid
    WHERE e.admit_date BETWEEN :startDate AND :endDate
          AND NOT EXISTS(SELECT *
                         FROM pcori_cdmv3.procedures pro (NOLOCK)
                         WHERE pro.proceduresid = pr.proceduresid)"""

    private static final String SQL_VITAL = """
USE <%=database%>

INSERT INTO pcori_cdmv3.vital (
    vitalid,
    patid,
    encounterid,
    measure_date,
    measure_time,
    vital_source,
    ht,
    wt,
    diastolic,
    systolic,
    original_bmi,
    bp_position,
    smoking,
    tobacco,
    tobacco_type,
    raw_diastolic,
    raw_systolic,
    raw_bp_position,
    raw_smoking,
    raw_tobacco,
    raw_tobacco_type
)
    SELECT
        NEWID(),
        v.patid,
        v.encounterid,
        v.measure_date,
        v.measure_time,
        v.vital_source,
        v.ht,
        v.wt,
        v.diastolic,
        v.systolic,
        v.original_bmi,
        v.bp_position,
        v.smoking,
        v.tobacco,
        v.tobacco_type,
        v.raw_diastolic,
        v.raw_systolic,
        v.raw_bp_position,
        LEFT(v.raw_smoking, 255)       AS 'raw_smoking',
        LEFT(v.raw_tobacco, 255)       AS 'raw_tobacco',
        LEFT(v.raw_tobacco_type, 255)  AS 'raw_tobacco_type'
    FROM pcori_cdmv3.encounter e
        JOIN rdw_views.pcornetcdmv3.vital v ON v.encounterid = e.encounterid
                                               AND v.patid = e.patid
    WHERE e.admit_date BETWEEN :startDate AND :endDate
          AND NOT EXISTS(SELECT *
                         FROM pcori_cdmv3.vital vt (NOLOCK)
                         WHERE vt.patid = v.patid
                               AND vt.encounterid = v.encounterid
                               AND vt.measure_date = v.measure_date
                               AND vt.measure_time = v.measure_time)"""

    private static final String SQL_PRESCRIBING = """
USE <%=database%>

INSERT INTO pcori_cdmv3.prescribing (
    prescribingid,
    patid,
    encounterid,
    rx_providerid,
    rx_order_date,
    rx_order_time,
    rx_start_date,
    rx_end_date,
    rx_quantity,
    rx_refills,
    rx_days_supply,
    rx_frequency,
    rx_basis,
    rxnorm_cui,
    raw_rx_med_name,
    raw_rx_frequency,
    raw_rxnorm_cui
)
    SELECT
        pr.prescribingid,
        pr.patid,
        pr.encounterid,
        pr.rx_providerid,
        pr.rx_order_date,
        pr.rx_order_time,
        pr.rx_start_date,
        pr.rx_end_date,
        pr.rx_quantity,
        pr.rx_refills,
        pr.rx_days_supply,
        pr.rx_frequency,
        pr.rx_basis,
        pr.rxnorm_cui,
        pr.raw_rx_med_name,
        pr.raw_rx_frequency,
        pr.raw_rxnorm_cui
    FROM rdw_views.pcornetcdmv3.prescribing pr
        JOIN pcori_cdmv3.encounter e ON e.encounterid = pr.encounterid
                                                         AND e.patid = pr.patid
    WHERE e.admit_date BETWEEN :startDate AND :endDate
          AND NOT EXISTS(SELECT *
                         FROM pcori_cdmv3.prescribing p (NOLOCK)
                         WHERE p.prescribingid = pr.prescribingid
                               AND p.patid = pr.patid
                               AND p.encounterid = pr.encounterid)"""

    private static final String SQL_LAB_RESULT_CM = """
USE <%=database%>

INSERT INTO pcori_cdmv3.lab_result_cm (
    lab_result_cm_id,
    patid,
    encounterid,
    lab_name,
    specimen_source,
    lab_loinc,
    priority,
    result_loc,
    lab_px,
    lab_px_type,
    lab_order_date,
    specimen_date,
    specimen_time,
    result_date,
    result_time,
    result_qual,
    result_num,
    result_modifier,
    result_unit,
    norm_range_low,
    norm_modifier_low,
    norm_range_high,
    norm_modifier_high,
    abn_ind,
    raw_lab_name,
    raw_lab_code,
    raw_panel,
    raw_result,
    raw_unit,
    raw_order_dept,
    raw_facility_code
)
    SELECT
        l.lab_result_cm_id,
        l.patid,
        l.encounterid,
        LEFT(l.lab_name, 10)            AS 'lab_name',
        LEFT(l.specimen_source, 10)     AS 'specimen_source',
        LEFT(l.lab_loinc, 10)           AS 'lab_loinc',
        LEFT(l.priority, 2)             AS 'priority',
        LEFT(l.result_loc, 2)           AS 'result_loc',
        LEFT(l.lab_px, 11)              AS 'lab_px',
        LEFT(l.lab_px_type, 2)          AS 'lab_px_type',
        l.lab_order_date,
        l.specimen_date,
        LEFT(l.specimen_time, 5)        AS 'specimen_time',
        l.result_date, --
        LEFT(l.result_time, 5)          AS 'result_time',
        LEFT(l.result_qual, 12)         AS 'result_qual',
        l.result_num,
        LEFT(l.result_modifier, 2)      AS 'result_modifier',
        LEFT(l.result_unit, 11)         AS 'result_unit',
        LEFT(l.norm_range_low, 10)      AS 'norm_range_low',
        LEFT(l.norm_modifier_low, 2)    AS 'norm_modifier_low',
        LEFT(l.norm_range_high, 10)     AS 'norm_range_high',
        LEFT(l.norm_modifier_high, 2)   AS 'norm_modifier_high',
        LEFT(l.abn_ind, 2)              AS 'abn_ind',
        LEFT(l.raw_lab_name, 255)       AS 'raw_lab_name',
        LEFT(l.raw_lab_code, 255)       AS 'raw_lab_code',
        LEFT(l.raw_panel, 255)          AS 'raw_panel',
        LEFT(l.raw_result, 255)         AS 'raw_result',
        LEFT(l.raw_unit, 255)           AS 'raw_unit',
        LEFT(l.raw_order_dept, 255)     AS 'raw_order_dept',
        LEFT(l.raw_facility_code, 255)  AS 'raw_facility_code'
    FROM pcori_cdmv3.encounter e
        JOIN rdw_views.pcornetcdmv3.lab_result_cm l ON l.encounterid = e.encounterid
                                                       AND l.patid = e.patid
    WHERE
        l.lab_name IS NOT NULL
        AND e.admit_date BETWEEN :startDate AND :endDate
        AND NOT EXISTS(SELECT *
                       FROM pcori_cdmv3.lab_result_cm lab (NOLOCK)
                       WHERE lab.lab_result_cm_id = l.lab_result_cm_id)"""
}
