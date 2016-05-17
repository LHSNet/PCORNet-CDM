/*******************************************************************************
*  $Source: normalization $;
*    $Date: 2016/03/31
*    Study: PCORnet
*
*  Purpose: To consolidate PCORnet Data Characterization Query Package v3.01
*              results into one standardized dataset for reporting usage
* 
*   Inputs: DC Query Package SAS datasets
*
*  Outputs: <dmid>_dc_norm_<response date>.sas7bdat
*
*  Requirements:  
*                1) Program run in SAS 9.3 or higher
*                2) The entire DC Query Package of datasets in /dmlocal
*******************************************************************************/
options validvarname=upcase;

********************************************************************************;
*- Set LIBNAMES for data and output
*******************************************************************************;
libname pcordata "&qpath./dmlocal/";

********************************************************************************;
* Create macro variable for outputname
********************************************************************************;
data _null_;
     set pcordata.xtbl_l3_metadata;
     if name="RESPONSE_DATE" then call symput("r_date",strip(compress(value,'-')));
run;

%let qname=&dmid._dc_norm_&r_date;
********************************************************************************;
* Create working formats 
********************************************************************************;
proc format;
     value $dsn
       'DEM'='DEMOGRAPHIC'
       'DIA'='DIAGNOSIS'
       'ENC'='ENCOUNTER'
       'ENR'='ENROLLMENT'
       'PRO'='PROCEDURES'
       'VIT'='VITAL'
       ;
run;

********************************************************************************;
*- Need to rename ADMIT_DATE to PX_DATE if from previous version
********************************************************************************;
%let _pxdate=PX_DATE;

proc contents data=pcordata.pro_l3_pxdate_y noprint out=c_pxdate;
run;

proc sql noprint;
     select name into :_pxdate from c_pxdate
     where name="ADMIT_DATE";
quit;

********************************************************************************;
*- Macro to convert each DC query dataset to standard format -*;
********************************************************************************;
%macro _recordn(dsn=,type=,var=,scat=,addvar=,stdvar=1);
    data &dsn;
        length dc_name $100 table resultc statistic variable cross_variable 
               category cross_category $50;
        %if &dsn=PRO_L3_PXDATE_Y and &_pxdate=ADMIT_DATE %then %do;
            set pcordata.&dsn (rename=(admit_date=px_date) drop=datamartid query_package response_date);
        %end;
        %else %do;
            set pcordata.&dsn %if &stdvar=1 %then %do; 
                           (drop=datamartid query_package response_date) %end; ;
        %end;

        %if &dsn=VIT_L3_HT %then %do;
             if _n_=1 and ht_group="0-10" then ht_group="<0";
        %end;

        * create common variables based upon DC query name *;
        dc_name="&dsn";
        table=put(scan("&dsn",1,'_'),$dsn.);

        %if &dsn=XTBL_L3_METADATA %then %do;
            if substr(value,1,21)="Values outside of CDM" then value="Values outside of CDM specifications";
        %end;

        * create common variables based upon type of query *;
        %if &type=_recordn %then %do;
            variable="&var";
            %if &var=DX or &var=PX %then %do;
                category=strip(compress(&var,'.'));
            %end;
            %else %do;
                category=strip(&var);
            %end;
            cross_variable=" ";
            cross_category=" ";
        %end;
        %else %if &type=_n %then %do;
            variable=strip(&var);
            category=" ";
            cross_variable=" ";
            cross_category=" ";
        %end;
        %else %if &type=_stat %then %do;
            variable="&var";
            category=" ";
            cross_variable=" ";
            cross_category=" ";
        %end;
        %else %if &type=_cross %then %do;
            variable="&var";
            category=strip(&var);
            cross_variable="&scat";
            %if &scat=DX or &scat=PX %then %do;
                cross_category=strip(compress(&scat,'.'));
            %end;
            %else %do;
                cross_category=strip(&scat);
            %end;
        %end;
        %else %if &type=_xtbl %then %do;
            table=dataset;
            variable=strip(&var);
            category=" ";
            cross_variable=" ";
            cross_category=" ";
        %end;
    
        * array result variables to transpose *;
        array abc{*} &addvar;
        do i=1 to dim(abc);
          * write name of variable to variable result *;
          call vname(abc{i},statistic);
          * over-write for this type of query *;
          %if &type=_stat %then %do;
              statistic=strip(stat);
          %end;

          * create character and numeric result variables *;
          resultc=strip(abc{i});
          if resultc not in ("BT" " ") then do;
             if indexc(upcase(resultc),"ABCDEFGHIJKLMNOPQRSTUVWXYZ-_()")=0 
                then resultn=input(resultc,best.);
             else resultn=.;
          end;
          else if resultc in ("BT") then resultn=.t;
          else if resultc in (" ") then resultn=.;

          * output as transposed records *;
          output;
        end;

        keep dc_name table variable cross_variable category cross_category 
             statistic resultc resultn;
    run;
    
    * append to one like data structure *;
    proc append base=query data=&dsn;
    run;

%mend _recordn;

%_recordn(dsn=DEM_L3_N,type=_n,var=tag,addvar=all_n distinct_n null_n)
%_recordn(dsn=DEM_L3_AGEYRSDIST1,type=_stat,var=AGE,addvar=record_n)
%_recordn(dsn=DEM_L3_AGEYRSDIST2,type=_recordn,var=AGE_GROUP,addvar=record_n record_pct)
%_recordn(dsn=DEM_L3_HISPDIST,type=_recordn,var=HISPANIC,addvar=record_n record_pct)
%_recordn(dsn=DEM_L3_RACEDIST,type=_recordn,var=RACE,addvar=record_n record_pct)
%_recordn(dsn=DEM_L3_SEXDIST,type=_recordn,var=SEX,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_N,type=_n,var=tag,addvar=all_n distinct_n null_n)
%_recordn(dsn=ENC_L3_N_VISIT,type=_n,var=tag,addvar=all_n distinct_n null_n)
%_recordn(dsn=ENC_L3_ADMSRC,type=_recordn,var=ADMITTING_SOURCE,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_DRG,type=_recordn,var=DRG,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_DRG_TYPE,type=_recordn,var=DRG_TYPE,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_ADATE_Y,type=_recordn,var=ADMIT_DATE,addvar=record_n record_pct distinct_patid_n)
%_recordn(dsn=ENC_L3_ADATE_YM,type=_recordn,var=ADMIT_DATE,addvar=record_n )
%_recordn(dsn=ENC_L3_DDATE_Y,type=_recordn,var=DISCHARGE_DATE,addvar=record_n record_pct distinct_patid_n)
%_recordn(dsn=ENC_L3_DDATE_YM,type=_recordn,var=DISCHARGE_DATE,addvar=record_n )
%_recordn(dsn=ENC_L3_DISDISP,type=_recordn,var=DISCHARGE_DISPOSITION,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_DISSTAT,type=_recordn,var=DISCHARGE_STATUS,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_ENCTYPE,type=_recordn,var=ENC_TYPE,addvar=record_n record_pct distinct_visit_n distinct_patid_n)
%_recordn(dsn=ENC_L3_DASH1,type=_recordn,var=PERIOD,addvar=distinct_patid_n)
%_recordn(dsn=ENC_L3_DASH2,type=_recordn,var=PERIOD,addvar=distinct_patid_n)
%_recordn(dsn=ENC_L3_ENCTYPE_ADMRSC,type=_cross,var=ENC_TYPE,scat=ADMITTING_SOURCE,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_ENCTYPE_DRG,type=_cross,var=ENC_TYPE,scat=DRG,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_ENCTYPE_ADATE_YM,type=_cross,var=ENC_TYPE,scat=ADMIT_DATE,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_ENCTYPE_DDATE_YM,type=_cross,var=ENC_TYPE,scat=DISCHARGE_DATE,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_ENCTYPE_DISDISP,type=_cross,var=ENC_TYPE,scat=DISCHARGE_DISPOSITION,addvar=record_n record_pct)
%_recordn(dsn=ENC_L3_ENCTYPE_DISSTAT,type=_cross,var=ENC_TYPE,scat=DISCHARGE_STATUS,addvar=record_n record_pct)
%_recordn(dsn=DIA_L3_N,type=_n,var=tag,addvar=all_n distinct_n null_n)
%_recordn(dsn=DIA_L3_DX,type=_recordn,var=DX,addvar=record_n record_pct)
%_recordn(dsn=DIA_L3_DXSOURCE,type=_recordn,var=DX_SOURCE,addvar=record_n record_pct)
%_recordn(dsn=DIA_L3_PDX,type=_recordn,var=PDX,addvar=record_n record_pct)
%_recordn(dsn=DIA_L3_ADATE_Y,type=_recordn,var=ADMIT_DATE,addvar=record_n record_pct distinct_encid_n distinct_patid_n)
%_recordn(dsn=DIA_L3_ADATE_YM,type=_recordn,var=ADMIT_DATE,addvar=record_n )
%_recordn(dsn=DIA_L3_ENCTYPE,type=_recordn,var=ENC_TYPE,addvar=record_n record_pct)
%_recordn(dsn=DIA_L3_DASH1,type=_recordn,var=PERIOD,addvar=distinct_patid_n)
%_recordn(dsn=DIA_L3_DX_DXTYPE,type=_cross,var=DX_TYPE,scat=DX,addvar=record_n record_pct)
%_recordn(dsn=DIA_L3_DXTYPE_DXSOURCE,type=_cross,var=DX_TYPE,scat=DX_SOURCE,addvar=record_n record_pct)
%_recordn(dsn=DIA_L3_PDX_ENCTYPE,type=_cross,var=ENC_TYPE,scat=PDX,addvar=record_n record_pct)
%_recordn(dsn=DIA_L3_DXTYPE_ENCTYPE,type=_cross,var=ENC_TYPE,scat=DX_TYPE,addvar=record_n record_pct)
%_recordn(dsn=DIA_L3_ENCTYPE_ADATE_YM,type=_cross,var=ENC_TYPE,scat=ADMIT_DATE,addvar=record_n record_pct)
%_recordn(dsn=PRO_L3_N,type=_n,var=tag,addvar=all_n distinct_n null_n)
%_recordn(dsn=PRO_L3_PX,type=_recordn,var=PX,addvar=record_n record_pct)
%_recordn(dsn=PRO_L3_ADATE_Y,type=_recordn,var=ADMIT_DATE,addvar=record_n record_pct distinct_encid_n distinct_patid_n)
%_recordn(dsn=PRO_L3_ADATE_YM,type=_recordn,var=ADMIT_DATE,addvar=record_n )
%_recordn(dsn=PRO_L3_PXDATE_Y,type=_recordn,var=PX_DATE,addvar=record_n record_pct distinct_encid_n distinct_patid_n)
%_recordn(dsn=PRO_L3_ENCTYPE,type=_recordn,var=ENC_TYPE,addvar=record_n record_pct)
%_recordn(dsn=PRO_L3_PXSOURCE,type=_recordn,var=PX_SOURCE,addvar=record_n record_pct)
%_recordn(dsn=PRO_L3_PXTYPE_ENCTYPE,type=_cross,var=ENC_TYPE,scat=PX_TYPE,addvar=record_n record_pct)
%_recordn(dsn=PRO_L3_ENCTYPE_ADATE_YM,type=_cross,var=ENC_TYPE,scat=ADMIT_DATE,addvar=record_n record_pct)
%_recordn(dsn=PRO_L3_PX_PXTYPE,type=_cross,var=PX_TYPE,scat=PX,addvar=record_n record_pct)
%_recordn(dsn=ENR_L3_N,type=_n,var=tag,addvar=all_n distinct_n null_n)
%_recordn(dsn=ENR_L3_DIST_ENRMONTH,type=_recordn,var=ENROLL_M,addvar=record_n record_pct)
%_recordn(dsn=ENR_L3_DIST_ENRYEAR,type=_recordn,var=ENROLL_Y,addvar=record_n record_pct)
%_recordn(dsn=ENR_L3_ENR_YM,type=_recordn,var=MONTH,addvar=record_n record_pct)
%_recordn(dsn=ENR_L3_BASEDIST,type=_recordn,var=ENR_BASIS,addvar=record_n record_pct)
%_recordn(dsn=ENR_L3_DIST_END,type=_stat,var=ENROLLMENT END DATE,addvar=record_n)
%_recordn(dsn=ENR_L3_DIST_START,type=_stat,var=ENROLLMENT START DATE,addvar=record_n)
%_recordn(dsn=ENR_L3_PER_PATID,type=_stat,var=ENROLLMENT RECORDS PER PATID,addvar=record_n)
%_recordn(dsn=VIT_L3_N,type=_n,var=tag,addvar=all_n distinct_n null_n)
%_recordn(dsn=VIT_L3_MDATE_Y,type=_recordn,var=MEASURE_DATE,addvar=record_n record_pct distinct_patid_n)
%_recordn(dsn=VIT_L3_MDATE_YM,type=_recordn,var=MEASURE_DATE,addvar=record_n )
%_recordn(dsn=VIT_L3_VITAL_SOURCE,type=_recordn,var=VITAL_SOURCE,addvar=record_n record_pct)
%_recordn(dsn=VIT_L3_HT,type=_recordn,var=HT_GROUP,addvar=record_n record_pct distinct_patid_n)
%_recordn(dsn=VIT_L3_HT_DIST,type=_stat,var=HEIGHT,addvar=record_n)
%_recordn(dsn=VIT_L3_WT,type=_recordn,var=WT_GROUP,addvar=record_n record_pct distinct_patid_n)
%_recordn(dsn=VIT_L3_WT_DIST,type=_stat,var=WEIGHT,addvar=record_n)
%_recordn(dsn=VIT_L3_DIASTOLIC,type=_recordn,var=DIASTOLIC_GROUP,addvar=record_n record_pct)
%_recordn(dsn=VIT_L3_SYSTOLIC,type=_recordn,var=SYSTOLIC_GROUP,addvar=record_n record_pct)
%_recordn(dsn=VIT_L3_BMI,type=_recordn,var=BMI_GROUP,addvar=record_n record_pct)
%_recordn(dsn=VIT_L3_BP_POSITION_TYPE,type=_recordn,var=BP_POSITION,addvar=record_n record_pct)
%_recordn(dsn=VIT_L3_SMOKING,type=_recordn,var=SMOKING,addvar=record_n record_pct)
%_recordn(dsn=VIT_L3_TOBACCO,type=_recordn,var=TOBACCO,addvar=record_n record_pct)
%_recordn(dsn=VIT_L3_TOBACCO_TYPE,type=_recordn,var=TOBACCO_TYPE,addvar=record_n record_pct)
%_recordn(dsn=VIT_L3_DASH1,type=_recordn,var=PERIOD,addvar=distinct_patid_n)
%_recordn(dsn=XTBL_L3_DASH1,type=_recordn,var=PERIOD,addvar=distinct_patid_n)
%_recordn(dsn=XTBL_L3_METADATA,type=_n,var=name,addvar=value,stdvar=0)
%_recordn(dsn=XTBL_L3_DATES,type=_xtbl,var=tag,addvar=min max future_dt_n pre2010_n)

********************************************************************************;
*- Add standard variables -*;
********************************************************************************;
data query;
     if _n_=1 then set pcordata.xtbl_l3_metadata(where=(name="DATAMARTID") rename=(value=datamartid));
     if _n_=1 then set pcordata.xtbl_l3_metadata(where=(name="QUERY_PACKAGE") rename=(value=query_package));
     if _n_=1 then set pcordata.xtbl_l3_metadata(where=(name="RESPONSE_DATE") rename=(value=response_date));
     set query;

     attrib 
        datamartid     label='DATAMART ID'
        response_date  label='Response date of query package'
        query_package  label='Query package version'
        dc_name        label='Query name'
        table          label='Data table'
        variable       label='Query variable'
        cross_variable label='Query cross-table variable'
        category       label='Categorical value'
        cross_category label='Cross-table variable categorical value'
        statistic      label='Statistic'
        resultc        label='Result (character)'
        resultn        label='Result (numeric)'
     ;
run;
 
********************************************************************************;
*- Order variables and output as permanent dataset -*;
********************************************************************************;
proc sql;
     create table pcordata.&qname as select
         datamartid, response_date, query_package, dc_name, table, variable, 
           cross_variable, category, cross_category, statistic, resultc, resultn
     from query;
quit;
