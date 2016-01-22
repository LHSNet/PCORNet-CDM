/********************************************************************************
*  $Source: diagnostic $;
*    $Date: 2015/12/18
*    Study: PCORnet
*
*  Purpose: To provide DataMart metadata including conformance to PCORnet CDM 
*               SAS data structure
* 
*   Inputs: DataMart data
*
*  Outputs: 1) SAS transport file of DataMart meta-data 
*                (<DataMart Id>_<response date>_metadata.cpt)
*           2) PDF file of DataMart dataset collection compatability with
*                required Data Characterization structure
*                (<DataMart Id>_<response date>_diagnostic_results.pdf)
*
*  Assumptions: 
*               1) Program run in SAS 9.3 or higher
*               2) User stores DIAGNOSTIC.SAS and REQUIRED_STRUCTURE.CPT in the 
*                     same file location, which is not the location where the
*                     user source data resides
*               3) User provides libname path where data resides (section below)
*                     (Example: /ct/pcornet/data/)
*               4) User provides libname path where DIAGNOSTIC.SAS resides 
*                     (section below) (Example: /ct/pcornet/queries/)
*               5) User provides libname path where output should reside
*                     (section below) (Example: /ct/pcornet/queries/)
********************************************************************************/

*********************************************************************************
* Provide user defined values
********************************************************************************;
 /*Enter directory where data is stored:*/               %let dpath=/ct/pcornet_dc/data/;
 /*Enter directory where diagnostic program is stored:*/ %let qpath=/ct/pcornet_dc/queries/;
 /*Enter directory where to store diagnostic output:*/   %let opath=/ct/pcornet_dc/queries/output/;
*********************************************************************************
* End of user provided values
********************************************************************************;

********************************************************************************;
* Set LIBNAMES for data and output
*******************************************************************************;
libname pcordata "&dpath";

********************************************************************************;
* Set LIBNAME/filename to import DC Query Package reqd structure transport file
********************************************************************************;
filename tranfile "&qpath.required_structure.cpt";
libname cptdata "&qpath";

********************************************************************************;
* Flush working directories    
********************************************************************************;
proc datasets kill;
run;

********************************************************************************;
* Create macro variable from DataMart ID and program run date 
********************************************************************************;
data _null_;
     set pcordata.harvest;
     call symput("dmid",strip(datamartid));
     call symput("tday",left(put("&sysdate"d,yymmddn8.)));
run;

********************************************************************************;
* Create an external log file
********************************************************************************;
filename qlog "&opath.&dmid._&tday._diagnostic_results.log" lrecl=200;
proc printto log=qlog new;
run ;

********************************************************************************;
* Create format for order output
********************************************************************************;
proc format;
     value $ord
        "DEMOGRAPHIC"="01"
        "ENROLLMENT"="02"
        "ENCOUNTER"="03"
        "DIAGNOSIS"="04"
        "PROCEDURES"="05"
        "VITAL"="06"
        "DISPENSING"="07"
        "LAB_RESULT_CM"="08"
        "CONDITION"="09"
        "PRO_CM"="10"
        "PRESCRIBING"="11"
        "PCORNET_TRIAL"="12"
        "DEATH"="13"
        "DEATH_CAUSE"="14"
        "HARVEST"="15"
        other=" "
        ;
run;

********************************************************************************;
* Begin diagnostic code 
********************************************************************************;

*- Get meta-data from DataMart data structures -*;
proc contents data=pcordata._all_ noprint out=datamart_all;
run;

*- Create ordering variable for output -*;
data datamart_all;
     set datamart_all;
     memname=upcase(memname);
     name=upcase(name);
     ord=put(upcase(memname),$ord.);

     * subset on required data structures *;
     if ord^=' ';
run;

*- Place all table names into a macro variable -*;
proc sql noprint;
     select unique memname into :workdata separated by '|'  from datamart_all;
     select count(unique memname) into :workdata_count from datamart_all;
quit;

*- Obtain the number of observations from each table -*;
%macro nobs;
    %do d = 1 %to &workdata_count;
        %let _dsn=%scan(&workdata,&d,"|");

        *- Get the number of obs from each dataset -*;
        proc sql inobs=1;
             create table nobs&d as
             select count(*) as nobs from pcordata.&_dsn;
        quit;

        data nobs&d;
             length memname $32;
             set nobs&d;
             memname="&_dsn";
             ord=put(upcase(memname),$ord.);
             output;
        run;

        * compile into one dataset *;
        proc append base=nobs_all data=nobs&d;
        run;
    %end;
%mend nobs;
%nobs;

*- Add number of observations -*;
proc sort data=datamart_all;
     by ord memname;
run;

proc sort data=nobs_all;
     by ord memname;
run;

data datamart_all;
     merge datamart_all(in=dm drop=nobs) nobs_all;
     by ord memname;
     if dm;
run;

*- For field comparison -*;
proc sort data=datamart_all(keep=ord memname name type length nobs) out=datamart;
     by ord memname name;
run;

*- For table comparison -*;
proc sort data=datamart(keep=ord memname nobs) out=datamart_dsn nodupkey;
     by ord memname;
run;

*- Import transport file of Data Characterization Query Package required structure -*;
proc cimport library=cptdata infile=tranfile;
run;

*- Create ordering variable for output -*;
data required_structure;
     set cptdata.required_structure;
     ord=put(upcase(memname),$ord.);
run;

*- For field comparison -*;
proc sort data=required_structure nodupkey;
     by ord memname name;
run;

*- For table comparison -*;
proc sort data=required_structure(keep=ord memname current_version) 
     out=required_structure_dsn nodupkey;
     by ord memname;
run;

*- Table comparison -*;
data compare_dsn;
     length condition $100;
     merge required_structure_dsn(in=r)
           datamart_dsn(in=dm)
     ;
     by ord memname;
        
     * keep if required *;
     if r;
     
     * label condition *;
     if r and not dm then 
        condition="Table is not present";
     else if r and dm and nobs<=0 then 
        condition="Table is present, meets requirements, and is not populated";
     else if r and dm then 
        condition="Table is present, meets requirements, and is populated";
run;

*- Field comparison -*;
data compare_var;
     length condition $100;
     merge required_structure(in=r)
           datamart(in=dm)
     ;
     by ord memname name;

     * keep if present in required, but not datamart or field type/length is mismatched *;
     if (r and not dm) or (r and dm and r_type^=type) or 
        (r and dm and r_type=2 and r_length^=. and length^=r_length);
     
     * label condition *;
     if r and not dm and r_type=2 then 
        condition="Required character field is not present";
     else if r and not dm and r_type=1 then 
        condition="Required numeric field is not present";
     else if r and dm and r_type^=type and r_type=2 then 
        condition="Required character field is numeric";
     else if r and dm and r_type^=type and r_type=1 then 
        condition="Required numeric field is character";
     else if r and dm and r_type=type and r_type=2 and r_length^=. and length^=r_length then 
        condition="Required character field is present but of unexpected length";
run;

*- Remove records from field comparison if no comparative table/obs present -*;
data compare_var;
     merge compare_var(in=dm)
           compare_dsn(in=mdsn rename=(condition=mprob) 
              where=(mprob in ("Table is not present")))
           compare_dsn(in=cdsn rename=(condition=cprob) 
              where=(cprob="Table is present, meets requirements, and is populated"))
     ;
     by ord memname;
     if mdsn then delete;
     if cdsn and not dm then condition=cprob;
run;

*- Set table and field records together -*;
data compare;
     set compare_dsn(where=(condition in ("Table is not present"
                            "Table is present, meets requirements, and is not populated")))
         compare_var;
     by ord memname;
     if condition="Table is present, meets requirements, and is not populated" and
        not (first.memname and last.memname) then 
        condition="Table is present and is not populated";
run;

*******************************************************************************;
*- Print options for trouble-shooting, if necessary -*;
*******************************************************************************;
proc options nohost;
run;

*******************************************************************************;
* Close log
*******************************************************************************;
proc printto;
run ;
*******************************************************************************;

*******************************************************************************;
*- Print discrepancies
*******************************************************************************;
ods html close;
ods listing close;
ods path sashelp.tmplmst(read) library.templat(read);
ods pdf file="&opath.&dmid._&tday._diagnostic_results.pdf" style=journal;
title3 "PCORnet CDM Diagnostic Report V3.00";
proc print width=min data=compare label;
     by ord memname;
     id memname;
     var name condition;
     label ord="Table number"
           memname="Table Name"
           name="Field Name"
           condition="Condition"
     ;
run;
ods listing;
ods pdf close;

*- Create a SAS transport file of DataMart metadata -*;
filename metafile "&opath.&dmid._&tday._metadata.cpt";
proc cport library=work file=metafile memtype=data;
     select datamart_all;
run;
