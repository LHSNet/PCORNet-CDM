/*******************************************************************************
*  $Source: dce_report $;
*    $Date: 2016/03/29
*    Study: PCORnet
*
*  Purpose: Produce PCORnet DCE report
* 
*   Inputs: SAS program:  /sasprograms/run_queries.sas
*
*  Outputs: 
*           1) Print of compiled DCE report in RTF file format stored as
*                (<DataMart Id>_DCERPT_<response date>.rtf)
*
*  Requirements: Program run in SAS 9.3 or higher
********************************************************************************/
options nodate nonumber nobyline orientation=landscape formchar="|___|||___+=|_/\<>"
        validvarname=upcase;
goptions reset=all dev=png rotate=landscape gsfmode=replace htext=0.9 
         ftext='Albany AMT' hsize=9 vsize=5.5;
ods html close;

********************************************************************************;
*- Set LIBNAMES for data and output
*******************************************************************************;
libname normdata "&qpath./dmlocal";
libname dmlocal "&qpath.dmlocal";

********************************************************************************;
* Call RTF template
********************************************************************************;
%include "&qpath.infolder/dce_template.sas";

********************************************************************************;
* Create macro variable from DataMart ID and program run date 
********************************************************************************;
data _null_;
     set normdata.xtbl_l3_metadata;
     if name="RESPONSE_DATE" then call symput("r_date",strip(compress(value,'-')));
run;

*******************************************************************************;
* Create an external log file
*******************************************************************************;
filename qlog "&qpath.dmlocal/&dmid._DCERPT_&r_date..log" lrecl=200;
proc printto log=qlog  new ;
run ;

********************************************************************************;
* Create standard macros used in multiple queries
********************************************************************************;

*- Get titles and footnotes -;
%macro ttl_ftn;
    data _null_;
         set footers;
         if table="&_ftn";
         call symput("_fnote",strip(footnote));
    run;

    data _null_;
         set headers;
         if table="&_hdr";
         call symput("_ttl1",strip(title1));
         call symput("_ttl2",strip(title2));
    run;
%mend ttl_ftn;

********************************************************************************;
* Create working formats used in multiple queries
********************************************************************************;
proc format;
     value tbl_row
       1='DEMOGRAPHIC'
       2='ENROLLMENT'
       3='ENCOUNTER'
       4='DIAGNOSIS'
       5='PROCEDURES'
       6='VITAL'
       7='HARVEST'
        ;

     value threshold
       .t="BT"
        ;

     value $etype
        'AV'='AV (Ambulatory Visit)'
        'ED'='ED (Emergency Dept)'
        'EI'='EI (ED to IP Stay)'
        'IP'='IP (Inpatient Hospital Stay)'
        'IS'='IS (Non-acute Institutional Stay)'
        'OA'='OA (Other Ambulatory Visit)'
        'Missing, NI, UN or OT'='Missing, NI, UN or OT'
        'TOTAL'='Total'
        ;
    
     value $svar
        'AV'='1'
        'ED'='2'
        'EI'='3'
        'IP'='4'
        'IS'='5'
        'OA'='6'
        'Missing, NI, UN or OT'='7'
        'TOTAL'='8'
         ;
run;

********************************************************************************;
* Create working datasets for TOC, headers, and footnotes 
********************************************************************************;
%macro toc(fname=,sheet=);

*- Import data from spreadsheet -*;

proc import file="&qpath.infolder/toc_header_footer.xlsx"
     out=&fname dbms=xlsx replace;
     sheet="&sheet";
     getnames=yes;
run;

data &fname;
     set &fname;
     if table^=" ";
run;

%mend toc;
%toc(fname=toc,sheet=Table of Contents)
%toc(fname=footers,sheet=Footers)
%toc(fname=headers,sheet=Headers)

********************************************************************************;
*- Macro to remove working datasets after each query result -*;
********************************************************************************;
%macro clean(savedsn);
     proc datasets  noprint;
          save dc_normal toc headers footers &savedsn / memtype=data;
          save formats / memtype=catalog;
     quit;
%mend clean;

********************************************************************************;
* Bring in NORMALIZED data and compress it
********************************************************************************;
data dc_normal(compress=yes);
     set normdata.&dmid._dc_norm_&r_date;
run;

********************************************************************************;
* (1) TABLE OF CONTENTS report
********************************************************************************;

*- Create macro variable for output name -*;
%let fname=tbl_toc;
%let _ftn=TOC;
%let _hdr=TOC;

*- Get titles and footnotes -;
%ttl_ftn;

data _null_;
     set dc_normal;
     if dc_name="XTBL_L3_METADATA" and variable="LOW_CELL_CNT" then call symput("low_cell",strip(resultc));
run;

*- Produce output -;
ods listing close;
ods path sashelp.tmplmst(read) work.templat(read);
ods rtf file = "&qpath.dmlocal/&dmid._DCERPT_&r_date..rtf" style=pcornet_dctl nogtitle nogfootnote;

title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
title3 justify=left h=2.5 "DataMart:  &dmid";
title4 justify=left h=2.5 "Response Date:  &r_date";
title5 justify=left h=2.5 "Low Cell Count Threshold:  &low_cell";
footnote1 justify=left "&_fnote";

proc report data=toc split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column section table table_description data_check_s_;

     define section           /display flow "Section" style(header)=[just=left cellwidth=35%] style(column)=[just=left];
     define table             /display flow "Table" style(header)=[just=left cellwidth=8%] style(column)=[just=left];
     define table_description /display flow "Table Description" style(header)=[just=left cellwidth=45%] style(column)=[just=left];
     define data_check_s_     /display flow "Data Check(s)" style(header)=[just=left cellwidth=10%] style(column)=[just=left];
run;    

ods listing;

********************************************************************************;
* (2) DEMOGRAPHIC SUMMARY
********************************************************************************;

*- Create macro variable for output name -*;
%let _ftn=STANDARD;
%let _hdr=Table IA;

*- Get titles and footnotes -*;
%ttl_ftn;

*- Create table formats -*;
proc format;
     value rowfmt
        0='Patients'
        1='Age'
        2='Age group'
        3='Hispanic'
        4='Sex'
        5='Race'
         ;

     value dc_name
        0='DEM_L3_N'
        1='DEM_L3_AGEYRSDIST1'
        2='DEM_L3_AGEYRSDIST2'
        3='DEM_L3_HISPDIST'
        4='DEM_L3_SEXDIST'
        5='DEM_L3_RACEDIST'
         ;

     value $agegroup
        "<0 yrs"='4'
        "0-1 yrs"='1'
        "2-4 yrs"='1'
        "5-9 yrs"='1'
        "10-14 yrs"='1'
        "15-18 yrs"='1'
        "19-21 yrs"='2'
        "22-44 yrs"='2'
        "45-64 yrs"='2'
        "65-74 yrs"='3'
        "75-110 yrs"='3'
        ">110 yrs"='3'
        "NULL or missing"='4'
        ;
run;

*- Create macro based upon row type -*;
%macro stat(dcn=,stat=,cat=,ord=,ord2=,col1=);
     if dc_name="&dcn" and statistic="&stat" then do;
        ord=&ord;
        ord2=&ord2;
        col1="&col1";
        output;
     end;
%mend stat;

%macro cat(dcn=,stat=,cat=,ord=,ord2=,col1=);
     if dc_name="&dcn" and category="&cat" then do;
        ord=&ord;
        ord2=&ord2;
        col1="&col1";
        output;
     end;
%mend cat;

*- Create dummy row dataset -*;
data dummy;
     length col1 col4 $200;
     do ord = 0 to 5;
        ord2=0;
        col1=put(ord,rowfmt.);
        col4=put(ord,dc_name.);
        output;
     end;
run;

data demog newcat;
     set dc_normal(where=(datamartid=%upcase("&dmid") and scan(dc_name,1,'_')="DEM"));
     if dc_name in ("DEM_L3_N" "DEM_L3_AGEYRSDIST1") then output demog;
     else output newcat;
run;

*- Special re-categorizing -*;
data newcat;
     length cat $50;
     set newcat;

     if dc_name="DEM_L3_AGEYRSDIST2" then cat=strip(put(category,$agegroup.));
     else if category in ("NI" "UN" "OT" "NULL or missing") then cat="Missing, NI, UN or OT";
     else cat=category;

     * flag BT records *;
     if resultn=.t and statistic="RECORD_N" then do;
        bt_flag="*";
        resultn=.;
     end;
     if resultn=. then resultn=0;

     keep dc_name statistic cat resultn bt_flag;
run;

*- Recalculate count and percent -*;
proc means data=newcat nway noprint missing;
     class dc_name statistic cat bt_flag;
     var resultn;
     output out=newcat_sum sum=sum;
run;

*- Reconfigure to match original normalized data -*;
data newcat_sum(keep=dc_name statistic category resultn bt_flag);
     length category $50;
     merge newcat_sum(rename=(bt_flag=flag) where=(flag=" "))
           newcat_sum(in=bt drop=sum where=(bt_flag="*"))
     ;
     by dc_name statistic cat;

     resultn=sum;
     category=cat;
run;

*- Create rows -*;
data tbl(keep=ord ord2 col1 resultc dc_name statistic);
     length col1 resultc $200;
     set demog newcat_sum;

     if statistic^="RECORD_PCT" then do;
         if resultn^=.t then resultc=strip(put(resultn,comma16.)||strip(bt_flag));
         else resultc=strip(put(resultn,threshold.));
     end;
     else if statistic="RECORD_PCT" then resultc=strip(put(resultn,5.1));

     %stat(dcn=DEM_L3_N,stat=DISTINCT_N,ord=0,ord2=0,col1=Patients)
     %stat(dcn=DEM_L3_AGEYRSDIST1,stat=MEAN,ord=1,ord2=1,col1=Mean)
     %stat(dcn=DEM_L3_AGEYRSDIST1,stat=MEDIAN,ord=1,ord2=2,col1=Median)
     %cat(dcn=DEM_L3_AGEYRSDIST2,cat=1,ord=2,ord2=1,col1=0-18)
     %cat(dcn=DEM_L3_AGEYRSDIST2,cat=2,ord=2,ord2=2,col1=19-64)
     %cat(dcn=DEM_L3_AGEYRSDIST2,cat=3,ord=2,ord2=3,col1=65+)
     %cat(dcn=DEM_L3_AGEYRSDIST2,cat=4,ord=2,ord2=4,col1=%str(Missing, NI, UN or OT))
     %cat(dcn=DEM_L3_HISPDIST,cat=N,ord=3,ord2=1,col1=N (No))
     %cat(dcn=DEM_L3_HISPDIST,cat=R,ord=3,ord2=2,col1=R (Refused))
     %cat(dcn=DEM_L3_HISPDIST,cat=Y,ord=3,ord2=3,col1=Y (Yes))
     %cat(dcn=DEM_L3_HISPDIST,cat=%str(Missing, NI, UN or OT),ord=3,ord2=4,col1=%str(Missing, NI, UN or OT))
     %cat(dcn=DEM_L3_SEXDIST,cat=A,ord=4,ord2=1,col1=A (Ambiguous))
     %cat(dcn=DEM_L3_SEXDIST,cat=F,ord=4,ord2=2,col1=F (Female))
     %cat(dcn=DEM_L3_SEXDIST,cat=M,ord=4,ord2=3,col1=M (Male))
     %cat(dcn=DEM_L3_SEXDIST,cat=%str(Missing, NI, UN or OT),ord=4,ord2=4,col1=%str(Missing, NI, UN or OT))
     %cat(dcn=DEM_L3_RACEDIST,cat=01,ord=5,ord2=1,col1=01 (American Indian or Alaska Native))
     %cat(dcn=DEM_L3_RACEDIST,cat=02,ord=5,ord2=2,col1=02 (Asian))
     %cat(dcn=DEM_L3_RACEDIST,cat=03,ord=5,ord2=3,col1=03 (Black or African American))
     %cat(dcn=DEM_L3_RACEDIST,cat=04,ord=5,ord2=4,col1=04 (Native Hawaiian or Other Pacific Islander))
     %cat(dcn=DEM_L3_RACEDIST,cat=05,ord=5,ord2=5,col1=05 (White))
     %cat(dcn=DEM_L3_RACEDIST,cat=06,ord=5,ord2=6,col1=06 (Multiple Race))
     %cat(dcn=DEM_L3_RACEDIST,cat=07,ord=5,ord2=7,col1=07 (Refuse to answer))
     %cat(dcn=DEM_L3_RACEDIST,cat=%str(Missing, NI, UN or OT),ord=5,ord2=8,col1=%str(Missing, NI, UN or OT))
run;

proc sort data=tbl;
     by ord ord2;
run;

*- Bring everything together - separate count and percent records -*;
data final;
     merge dummy
           tbl(where=(statistic^="RECORD_PCT") rename=(resultc=col2))
           tbl(where=(statistic="RECORD_PCT") rename=(resultc=col3))
     ;
     by ord ord2;
     if ord2^=0 then col1="\li200 " || strip(col1);
     if ord<=4 then pg=1;
     else pg=2;
run;
    
*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 col2 col3 col4;
     where pg=1;

     define pg       /order noprint;
     define col1     /display flow "" style(header)=[just=left cellwidth=40%] style(column)=[just=left];
     define col2     /display flow "N" style(column)=[just=center cellwidth=14%];
     define col3     /display flow "%" style(column)=[just=center cellwidth=14%];
     define col4     /display flow "Source table" style(header)=[just=left cellwidth=30%] style(column)=[just=left];
run;    

title1 justify=left "&_ttl1 (continued)";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 col2 col3 col4;
     where pg=2;

     define pg       /order noprint;
     define col1     /display flow "" style(header)=[just=left cellwidth=40%] style(column)=[just=left];
     define col2     /display flow "N" style(column)=[just=center cellwidth=14%];
     define col3     /display flow "%" style(column)=[just=center cellwidth=14%];
     define col4     /display flow "Source table" style(header)=[just=left cellwidth=30%] style(column)=[just=left];
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (3) DASHBOARD METRICS
********************************************************************************;

*- Create macro variable for output name -*;
%let _ftn=STANDARD;
%let _hdr=Table IB;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create table formats -*;
proc format;
     value metric
        1='Unique patients'
        2='Unique encounters'
        3='Potential pool of patients for observational studies'
        4='Potential pool of patients for trials'
        5='Unique patients with encounters and (a) vital signs, (b) diagnoses, and (c) both'
        6=' '
        7=' '
        ;

     value met_desc
        1='Number of unique patients with at least 1 encounter'
        2='Number of unique encounters'
        3='Number of unique patients with at least 1 ED, EI, IP, or AV encounter within the past 5 years'
        4='Number of unique patients with at least 1 ED, EI, IP, or AV encounter within the past 1 year'
        5='Number of unique patients with VITAL and ENCOUNTER records'
        6='Number of unique patients with DIAGNOSIS and ENCOUNTER records'
        7='Number of unique patients with DIAGNOSIS, VITAL and ENCOUNTER records'
        ;
run;

*- Create macro based upon row type -*;
%macro stat(dcn=,var=,stat=,cat=,ord=,type=);
    data row&ord;
         length col1-col3 $100;
         set dc_normal(where=(datamartid=%upcase("&dmid") and dc_name="&dcn"
             %if &type=1 %then %do; and variable="&var" and statistic="&stat" %end;
             %else %if &type=2 %then %do; and category="&cat" %end; ));

         ord=&ord;
         col1=put(ord,metric.);
         col2=put(ord,met_desc.);
         if resultn^=.t then col3=strip(put(resultn,comma16.));
         else col3=strip(put(resultn,threshold.));
         keep ord: col: dc_name;
    run;
        
    proc append base=tbl data=row&ord;
    run;

%mend stat;
%stat(dcn=ENC_L3_N,var=PATID,stat=DISTINCT_N,ord=1,type=1)
%stat(dcn=ENC_L3_N,var=ENCOUNTERID,stat=DISTINCT_N,ord=2,type=1)
%stat(dcn=ENC_L3_DASH2,cat=5 yrs,ord=3,type=2)
%stat(dcn=ENC_L3_DASH2,cat=1 yr,ord=4,type=2)
%stat(dcn=VIT_L3_DASH1,cat=All yrs,ord=5,type=2)
%stat(dcn=DIA_L3_DASH1,cat=All yrs,ord=6,type=2)
%stat(dcn=XTBL_L3_DASH1,cat=All yrs,ord=7,type=2)

*- Bring everything together -*;
data final;
     set tbl;
     by ord;
     pg=1;
run;
    
*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 col2 col3 dc_name;

     define pg       /order noprint;
     define col1     /display flow "Metric" style(header)=[just=left cellwidth=25%] style(column)=[just=left];
     define col2     /display flow "Metric Description" style(header)=[just=left cellwidth=45%] style(column)=[just=left];;
     define col3     /display flow "Result" style(header)=[just=center cellwidth=14%] style(column)=[just=left];
     define dc_name  /display flow "Source table" style(header)=[just=left cellwidth=15%] style(column)=[just=left];
    
     break after pg / page;
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (4) HEIGHT, WEIGHT, AND BMI
********************************************************************************;

%let _ftn=IC;
%let _hdr=Table IC;

*- Get titles and footnotes -;
%ttl_ftn;

********************************************************************************;
* Create table formats
********************************************************************************;
proc format;
     value rowfmt
        1='Height measurements'
        2='Weight measurements'
        3='Body Mass Index (BMI) measurements'
        ;

     value dc_name
        1='VIT_L3_HT_DIST'
        2='VIT_L3_WT_DIST'
        3='VIT_L3_BMI'
         ;

     value $bmigroup
        '0-1'='BMI <=25'
        '2-5'='BMI <=25'
        '6-10'='BMI <=25'
        '11-15'='BMI <=25'
        '16-20'='BMI <=25'
        '21-25'='BMI <=25'
        '26-30'='BMI 26-30'
        '31-35'='BMI >=31'
        '36-40'='BMI >=31'
        '41-45'='BMI >=31'
        '46-50'='BMI >=31'
        '>50'='BMI >=31'
        ;
run;

*- Create dummy row dataset -*;
data dummy;
     length col1 col4 $200;
     do ord = 1 to 3;
        ord2=0;
        col1=put(ord,rowfmt.);
        col4=put(ord,dc_name.);
        output;
     end;
run;

*- Re-categorize BMI -*;
data bmi;
     set dc_normal;
     if datamartid=%upcase("&dmid") and dc_name="VIT_L3_BMI" and statistic="RECORD_N" and 
           category not in ("<0" "NULL or missing");

     * flag BT records *;
     if resultn=.t and statistic="RECORD_N" then do;
        bt_flag="*";
        resultn=.;
     end;
     if resultn=. then resultn=0;

     keep dc_name category resultn bt_flag;
run;

proc means data=bmi completetypes nway missing noprint;
     class dc_name bt_flag;
     class category/preloadfmt;
     var resultn;
     output out=bmi_sum sum=sum;
     format category $bmigroup.;
run;

*- Create a total records record -*;
data bmi_total;
     merge bmi_sum(rename=(bt_flag=flag) where=(flag=" " and sum^=.))
           bmi_sum(in=bt rename=(sum=bt_sum) where=(bt_flag="*" and bt_sum^=.)) end=eof
     ;
     by dc_name category;
     output;
     retain total 0;
     total=total+sum;
     if eof then do;
        category="TOTAL";
        output;
     end;
run;

*- Create macro based upon row type -*;
%macro stat(dcn=,var=,stat=,cat=,ord=,ord2=,type=,col1=);
    data row&ord;
         length col1-col3 $50;
         %if &type=1 %then %do;
             set dc_normal(where=(datamartid=%upcase("&dmid") and dc_name="&dcn"
                                    and variable="&var" and statistic="&stat"));
                 if resultn^=.t then col2=strip(put(resultn,comma16.));
                 else col2=strip(put(resultn,threshold.));
                 col3=" ";
         %end;
         %else %if &type=2 %then %do; 
             if _n_=1 then set bmi_total(rename=(total=denom) where=(category="TOTAL"));
             set bmi_total(where=(category="&cat"));
                 col2=strip(put(&var,comma16.)||strip(bt_flag));
                 %if &var=sum %then %do;
                    col3=strip(put((&var/denom)*100,5.1));
                 %end;
                 %else %do;
                    col3=" ";
                 %end;
         %end;
         ord=&ord;
         ord2=&ord2;
         col1="&col1";
         keep ord: col:;
    run;

    proc append base=tbl data=row&ord;
    run;

%mend stat;
%stat(dcn=VIT_L3_HT_DIST,var=HEIGHT,stat=N,ord=1,ord2=1,type=1,col1=Records)
%stat(dcn=VIT_L3_HT_DIST,var=HEIGHT,stat=MEAN,ord=1,ord2=2,type=1,col1=%str(Height (inches), mean))
%stat(dcn=VIT_L3_HT_DIST,var=HEIGHT,stat=MEDIAN,ord=1,ord2=3,type=1,col1=%str(Height (inches), median))
%stat(dcn=VIT_L3_WT_DIST,var=WEIGHT,stat=N,ord=2,ord2=1,type=1,col1=Records)
%stat(dcn=VIT_L3_WT_DIST,var=WEIGHT,stat=MEAN,ord=2,ord2=2,type=1,col1=%str(Weight (lbs.), mean))
%stat(dcn=VIT_L3_WT_DIST,var=WEIGHT,stat=MEDIAN,ord=2,ord2=3,type=1,col1=%str(Weight (lbs.), median))
%stat(dcn=VIT_L3_BMI,var=total,cat=TOTAL,ord=3,ord2=1,type=2,col1=Records)
%stat(dcn=VIT_L3_BMI,var=sum,cat=0-1,ord=3,ord2=2,type=2,col1=BMI <=25)
%stat(dcn=VIT_L3_BMI,var=sum,cat=26-30,ord=3,ord2=3,type=2,col1=BMI 26-30)
%stat(dcn=VIT_L3_BMI,var=sum,cat=31-35,ord=3,ord2=4,type=2,col1=BMI >=31)

*- Bring everything together -*;
data final;
     merge dummy tbl;
     by ord ord2;
     if ord2^=0 then col1="\li200 " || strip(col1);
     pg=1;
run;
    
*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 col2 col3 col4;

     define pg       /order noprint;
     define col1     /display flow " " style(header)=[just=left cellwidth=30%] style(column)=[just=left];
     define col2     /display flow "Result" style(header)=[just=center cellwidth=15%] style(column)=[just=center];;
     define col3     /display flow "%" style(header)=[just=left cellwidth=10%] style(column)=[just=left];;
     define col4     /display flow "Source table" style(header)=[just=left cellwidth=43%] style(column)=[just=left];
    
     break after pg / page;
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (5) VITAL MEASUREMENTS
********************************************************************************;

*- Create macro variable for output name -*;
%let _hdr=Chart IA;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create dataset containing all month/year values -*;
data all_months;
         do yr = 2010 to 2015;
            do mon = 1 to 12;
                xdate=mdy(mon,1,yr);
                output;
            end;
        end;
run;

proc sort data=all_months(keep=xdate:);
     by xdate;
run;

*- Subset and create a month/year variable as a SAS date value -*;
data data;
     format xdate date9.;
     set dc_normal(where=(datamartid=%upcase("&dmid") and statistic="RECORD_N" and
         dc_name="VIT_L3_MDATE_YM" and category^="NULL or missing"));

     if resultn=.t then resultn=0;

     xdate=mdy(input(scan(category,2,'_'),2.),1,input(scan(category,1,'_'),4.));

     keep xdate resultn;
run;
    
proc sort data=data;
     by xdate;
run;

*- Determine first month within range where results exist -*;
proc means data=data nway noprint;
     var xdate;
     output out=cutdates min=begdt max=enddt;
     where '01JAN2010'd<=xdate and resultn>0;
run;

data all_months;
     format begdt enddt date9.;
     if _n_=1 then set cutdates(keep=begdt enddt);
     set all_months(in=a);
     if enddt>=xdate>=begdt>. then cut=0;
run;

*- Bring dummy and actual data together -*;
data final;
     format xdate date9.;
     merge all_months(in=a) data;
     by xdate;
     if a;

     if cut^=0 then resultn=.;
     else if resultn=. then resultn=0;

     retain count 0;    
     count=count+1;
run;
            
*- Produce output -*;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
symbol1  c=red line=1 v=NONE interpol=join;

axis1 order=(1 to 73 by 6) value=("Jan 2010" "Jul 2010" "Jan 2011" "Jul 2011" "Jan 2012" "Jul 2012" 
      "Jan 2013" "Jul 2013" "Jan 2014" "Jul 2014" "Jan 2015" "Jul 2015" "Jan 2016") label=("MEASURE_DATE" h=1.5)
      minor=none
      offset=(0.5,1);

axis2 label=(angle=90 "Vital Records" h=1.5)
      minor=(n=1)
      offset=(0.5,.75);

proc gplot data=final;
     plot resultn*count / haxis=axis1 vaxis=axis2 grid;
     format resultn comma16.;
run;
quit;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (6) RECORDS, PATIENTS, ENCOUNTERS, AND DATE RANGES BY TABLE
********************************************************************************;

%let _ftn=ID;
%let _hdr=Table ID;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create table formats -*;
proc format;
     value rowfmt
        1='\b Records \b0'
        2='\li200 N'
        3='\b Patients \bo'
        4='\li200 N'
        5='\b Encounters \b0'
        6='\li200 N'
        7='\b Date Range \b0'
        8='\li200 Field'
        9='\li200 Minimum'
       10='\li200 Maximum'
       11='\li200 % of records before Jan 2010'
       12='\b Source table(s) \b0'
        ;
run;

*- Subset and Re-categorize encounter type -*;
data data;
     set dc_normal(where=(datamartid=%upcase("&dmid") and scan(dc_name,3,'_')="N"
                            and variable in ("PATID" "ENCOUNTERID")));

     if statistic in ("ALL_N" "NULL_N") then stat=1;
     else stat=2;

     if resultn=. then resultn=0;

     keep table variable  stat resultn dc_name;
run;

*- Recalculate count and percent -*;
proc means data=data nway noprint;
     class variable stat table dc_name;
     var resultn;
     output out=stats sum=sum;
run;

data rpe;
     length resultc $50;
     if _n_=1 then set stats(where=(variable="PATID" and stat=1 and table="DEMOGRAPHIC") rename=(sum=dem_pat));
     if _n_=1 then set stats(where=(variable="PATID" and stat=2 and table="ENCOUNTER") rename=(sum=enc_pat));
     if _n_=1 then set stats(where=(variable="ENCOUNTERID" and stat=2 and table="ENCOUNTER") rename=(sum=enc_enc));
     set stats;

     resultc=strip(put(sum,comma16.));
     if variable="PATID" and stat=1 then do;
        ord=2;
        output;
     end;
     if variable="PATID" and stat=2 then do;
        ord=4;
        output;
     end;
     if variable="ENCOUNTERID" and stat=2 then do;
        ord=6;
        output;
     end;
run;

proc sort data=dc_normal(keep=datamartid dc_name table statistic result: variable)
     out=cross;
     by table;
     where datamartid=%upcase("&dmid") and dc_name="XTBL_L3_DATES";
run;

data cross;
     merge cross 
           stats(keep=table variable stat sum where=(dumvar="PATID" and stat=1) rename=(variable=dumvar))
     ;
     by table;

     if variable in ("DISCHARGE_DATE" "ENR_END_DATE" "PX_DATE") then delete;

     if statistic="FUTURE_DT_N" then do;
        ord=8;
        resultc=strip(variable);
        output;
     end;
     else if statistic="MIN" then do;
        ord=9;
        output;
     end;
     else if statistic="MAX" then do;
        ord=10;
        output;
     end;
     else if statistic="PRE2010_N" then do;
        ord=11;
        resultc=strip(put((resultn/sum)*100,5.1));
        output;
     end;
run;

data tbl;
     set rpe cross;
     output;
     if variable="PATID" and stat=1 then do;
         ord=12;
         resultc=strip(trim(dc_name) || "; XTBL_L3_DATES");
         output;
     end;
run;

proc sort;
     by ord;
run;

proc transpose data=tbl out=final;
     by ord;
     var resultc;
     id table;
run;

data label;
     do ord = 1 to 12;
        output;
     end;
run;       

*- Bring everything together -*;
data final;
     merge final label;
     by ord;

     * edit check flag for dates after 1/1/2010 *;
     array t demographic enrollment encounter diagnosis procedures vital;
     array f dem_fl enr_fl enc_fl dia_fl pro_fl vit_fl;
     if ord=9 then do;
        do i = 1 to dim(t);
            if t{i}^=" " and mdy(input(scan(t{i},2,'_'),2.),1,input(scan(t{i},1,'_'),4.))>'01JAN2010'd then f{i}=1;
            else f{i}=0;
        end;
     end;
     col1=strip(put(ord,rowfmt.));
     pg=1;
run;

*- Produce output -*;
ods listing close;

title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column dem_fl enr_fl enc_fl dia_fl pro_fl vit_fl pg col1 
            demographic enrollment encounter diagnosis procedures vital;

     define dem_fl      /display noprint;
     define enr_fl      /display noprint;
     define enc_fl      /display noprint;
     define dia_fl      /display noprint;
     define pro_fl      /display noprint;
     define vit_fl      /display noprint;
     define pg          /order noprint;
     define col1        /display flow " " style(header)=[just=left cellwidth=23%] style(column)=[just=left];
     define demographic /display flow "DEMOGRAPHIC" style(header)=[just=center cellwidth=12.5%] style(column)=[just=center];
     define enrollment  /display flow "ENROLLMENT" style(header)=[just=center cellwidth=12.5%] style(column)=[just=center];
     define encounter   /display flow "ENCOUNTER" style(header)=[just=center cellwidth=12.5%] style(column)=[just=center];
     define diagnosis   /display flow "DIAGNOSIS" style(header)=[just=center cellwidth=12.5%] style(column)=[just=center];
     define procedures  /display flow "PROCEDURES" style(header)=[just=center cellwidth=12.5%] style(column)=[just=center];
     define vital       /display flow "VITAL" style(header)=[just=center cellwidth=12.5%] style(column)=[just=center];
     compute demographic;
        if dem_fl=1 then call define(_col_, "style", "style=[color=red]");
     endcomp;
     compute enrollment;
        if enr_fl=1 then call define(_col_, "style", "style=[color=red]");
     endcomp;
     compute encounter;
        if enc_fl=1 then call define(_col_, "style", "style=[color=red]");
     endcomp;
     compute diagnosis;
        if dia_fl=1 then call define(_col_, "style", "style=[color=red]");
     endcomp;
     compute procedures;
        if pro_fl=1 then call define(_col_, "style", "style=[color=red]");
     endcomp;
     compute vital;
        if vit_fl=1 then call define(_col_, "style", "style=[color=red]");
     endcomp;
run;

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (7) RECORDS PER TABLE BY ENCOUNTER TYPE
********************************************************************************;

%let _ftn=STANDARD;
%let _hdr=Table IE;

*- Get titles and footnotes -;
%ttl_ftn;

*- Subset and Re-categorize encounter type -*;
data data;
     length cat $50;
     set dc_normal(where=(datamartid=%upcase("&dmid") and statistic="RECORD_N"
         and dc_name in ("DIA_L3_ENCTYPE" "PRO_L3_ENCTYPE" "ENC_L3_ENCTYPE")
         and category^="Values outside of CDM specifications"));

     * re-categorize encounter type *;
     if category in ("NI" "UN" "OT" "NULL or missing") then cat="Missing, NI, UN or OT";
     else cat=category;

     * flag BT records *;
     if resultn=.t and statistic="RECORD_N" then do;
        bt_flag="*";
        resultn=.;
     end;
     if resultn=. then resultn=0;
     output;
     cat="TOTAL";
     output;
     keep dc_name cat resultn bt_flag;
run;

*- Summarize counts on new encounter type -*;
proc means data=data missing nway noprint;
     class dc_name cat bt_flag;
     var resultn;
     output out=stats sum=sum;
run;

proc sort;
     by dc_name;
run;

data stats;
     merge stats(rename=(bt_flag=flag) where=(flag=" "))
           stats(in=bt drop=sum where=(bt_flag="*"))
     ;
     by dc_name cat;
run;

data stats;
     merge stats
           stats(keep=dc_name cat sum rename=(cat=totcat sum=denom) where=(totcat="TOTAL"))
     ;
     by dc_name;
run;

proc sort;
     by cat;
run;

*- Bring everything together -*;
data final(keep=pg ord col: enc_fl dia_fl pro_fl);
     length col1-col7 $50;
     merge stats(where=(scan(dc_name,1,'_')="DIA") rename=(sum=diagnosis denom=dia_den bt_flag=bt_dia))
           stats(where=(scan(dc_name,1,'_')="PRO") rename=(sum=procedure denom=pro_den bt_flag=bt_pro))
           stats(where=(scan(dc_name,1,'_')="ENC") rename=(sum=encounter denom=enc_den bt_flag=bt_enc))
     ;
     by cat;

     ord=put(cat,$svar.);
     col1=strip(put(cat,$etype.));

     if encounter=. and bt_enc="*" then col2=strip(put(.t,threshold.));
     else col2=strip(put(encounter,comma16.));
     if cat^="TOTAL" and encounter>0 and enc_den>0 then col3=strip(put((encounter/enc_den)*100,16.1));

     if diagnosis=. and bt_dia="*" then col4=strip(put(.t,threshold.));
     else col4=strip(put(diagnosis,comma16.));
     if cat^="TOTAL" and diagnosis>0 and dia_den>0 then col5=strip(put((diagnosis/dia_den)*100,16.1));

     if procedure=. and bt_pro="*" then col6=strip(put(.t,threshold.));
     else col6=strip(put(procedure,comma16.));
     if cat^="TOTAL" and procedure>0 and pro_den>0 then col7=strip(put((procedure/pro_den)*100,16.1));

     pg=1;
    
     if ord in ('1' '2' '4') then do;
        if encounter<=0 then enc_fl=1;
        if diagnosis<=0 then dia_fl=1;
        if procedure<=0 then pro_fl=1;
     end;

     output;
     if cat="TOTAL" then do;
        ord="9";
        col1="Source table";
        col2="ENC_L3_ENCTYPE";
        col3=" ";
        col4="DIA_L3_ENCTYPE";
        col5=" ";
        col6="PRO_L3_ENCTTPE";
        col7=" ";
        output;
     end;
run;

proc sort;
     by ord;
run;

*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column enc_fl dia_fl pro_fl pg col1 
            ("ENCOUNTER~_______________________________" col2 col3) 
            ("DIAGNOSIS~_______________________________" col4 col5)
            ("PROCEDURES~______________________________" col6 col7);

     define enc_fl   /display noprint;
     define dia_fl   /display noprint;
     define pro_fl   /display noprint;
     define pg       /order noprint;
     define col1     /display flow "Encounter Type" style(header)=[just=left cellwidth=32%] style(column)=[just=left];
     define col2     /display flow "N" style(header)=[just=center cellwidth=15%] style(column)=[just=center];
     define col3     /display flow "%" style(header)=[just=center cellwidth=7%] style(column)=[just=center];
     define col4     /display flow "N" style(header)=[just=center cellwidth=15%] style(column)=[just=center];
     define col5     /display flow "%" style(header)=[just=center cellwidth=7%] style(column)=[just=center];
     define col6     /display flow "N" style(header)=[just=center cellwidth=15%] style(column)=[just=center];
     define col7     /display flow "%" style(header)=[just=center cellwidth=7%] style(column)=[just=center];
     compute col2;
        if enc_fl=1 then call define(_col_, "style", "style=[color=red]");
     endcomp;
     compute col4;
        if dia_fl=1 then call define(_col_, "style", "style=[color=red]");
     endcomp;
     compute col6;
        if pro_fl=1 then call define(_col_, "style", "style=[color=red]");
     endcomp;
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (8) RECORDS PER TABLE BY YEAR
********************************************************************************;

%let _ftn=IF;
%let _hdr=Table IF;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create table formats -*;
proc format;
     value yr
        1111='<2010'
        9998='Total'
        9999='Source'
        ;
run;

*- Subset normalized data and create numeric year variable -*;
data data;
     set dc_normal(where=(datamartid=%upcase("&dmid") and statistic="RECORD_N" 
            and dc_name in ("ENC_L3_ADATE_Y" "ENR_L3_ENR_YM" "DIA_L3_ADATE_Y" "PRO_L3_ADATE_Y" "VIT_L3_MDATE_Y")));

     if category^="NULL or missing" then do;
        if dc_name="ENR_L3_ENR_YM" then year=input(scan(category,1,'_'),4.);
        else year=input(category,4.);
     end;
     else delete;
    
     if year<year(today())-6 then year=1111;
     else if year>=year(today()) then year=year(today());
run;

*- Calculate totals by query name and year -*;
proc means data=data noprint;
     class dc_name year;
     var resultn;
     output out=stats sum=sum;
run;

proc sort data=stats;
     by dc_name;
     where _type_ in (2,3);
run;

*- Add denominators, derive percentage, output source row -*;
data tbl;
     length coln colp $50;
     merge stats(where=(_type_ in (2,3)))
           stats(drop=year where=(_type_=2) rename=(sum=denom))
     ;
     by dc_name;

     * create sorting variable *;
     if _type_=2 then svar=9998;
     else svar=year;

     * create N and % variables and output *;
     if sum^=.t then coln=strip(put(sum,comma16.));
     else coln=strip(put(sum,threshold.));
     if _type_=3 then colp=put((sum/denom)*100,3.);
     output;

     * create source row *;
     if _type_=2 then do;
        svar=9999;
        coln=strip(dc_name);
        colp=" ";
        output;
     end;
run;

proc sort data=tbl(drop=year);
     by svar;
run;

*- Bring everything together - separate count and percent records -*;
data final;
     merge tbl(where=(dc_name="ENC_L3_ADATE_Y") rename=(coln=col4 colp=col5))
           tbl(where=(dc_name="ENR_L3_ENR_YM") rename=(coln=col2 colp=col3))
           tbl(where=(dc_name="DIA_L3_ADATE_Y") rename=(coln=col6 colp=col7)) 
           tbl(where=(dc_name="PRO_L3_ADATE_Y") rename=(coln=col8 colp=col9))
           tbl(where=(dc_name="VIT_L3_MDATE_Y") rename=(coln=col10 colp=col11))
     ;
     by svar;

     if svar=year(today()) then col1=">="||put(year(today()),4.);
     else col1=put(svar,yr.);
     pg=1;
run;
    
*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 ("ENROLLMENT~________________________" col2 col3) ("ENCOUNTER~________________________" col4 col5) 
                    ("DIAGNOSIS~________________________" col6 col7) ("PROCEDURES~________________________" col8 col9)
                    ("VITAL~________________________" col10 col11);

     define pg       /order noprint;
     define col1     /display flow "Year" style(header)=[just=left cellwidth=10%] style(column)=[just=left];
     define col2     /display flow "N" style(header)=[just=center cellwidth=12%] style(column)=[just=left];
     define col3     /display flow "%" style(header)=[just=center cellwidth=5%] style(column)=[just=left];
     define col4     /display flow "N" style(header)=[just=center cellwidth=12%] style(column)=[just=left];
     define col5     /display flow "%" style(header)=[just=center cellwidth=5%] style(column)=[just=left];
     define col6     /display flow "N" style(header)=[just=center cellwidth=12%] style(column)=[just=left];
     define col7     /display flow "%" style(header)=[just=center cellwidth=5%] style(column)=[just=left];
     define col8     /display flow "N" style(header)=[just=center cellwidth=12%] style(column)=[just=left];
     define col9     /display flow "%" style(header)=[just=center cellwidth=5%] style(column)=[just=left];
     define col10    /display flow "N" style(header)=[just=center cellwidth=12%] style(column)=[just=left];
     define col11    /display flow "%" style(header)=[just=center cellwidth=5%] style(column)=[just=left];
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (9) TREND IN ENCOUNTERS BY ADMIT DATE AND ENCOUNTER TYPE
********************************************************************************;
%let _hdr=Chart IB;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create formats -*;
proc format;
     value $cat
        'AV'='AV (Ambulatory Visit)'
        'ED'='ED (Emergency Dept)'
        'EI'='EI (ED to IP Stay)'
        'IP'='IP (Inpatient Hospital Stay)'
        'IS'='IS (Non-acute Institutional Stay)'
        'OA'='OA (Other Ambulatory Visit)'
        ;
run;

*- Create dataset containing all month/year values -*;
data all_months;
     format xdate date9.;
     length category $200;
     do category = "ED", "EI", "IP", "IS", "OA", "AV";
         do yr = 2010 to 2015;
            do mon = 1 to 12;
                xdate=mdy(mon,1,yr);
                output;
            end;
        end;
     end;
run;

proc sort data=all_months(keep=category xdate);
     by category xdate;
run;

*- Subset and create a month/year variable as a SAS date value -*;
data data;
     format xdate date9.;
     set dc_normal(where=(datamartid=%upcase("&dmid") and statistic="RECORD_N" and
         dc_name="ENC_L3_ENCTYPE_ADATE_YM" and category in ("ED" "EI" "IP" "IS" "OA" "AV")
         and cross_category^="NULL or missing"));

     if resultn=.t then resultn=0;

     xdate=mdy(input(scan(cross_category,2,'_'),2.),1,input(scan(cross_category,1,'_'),4.));
    
     keep category xdate resultn;
run;
    
proc sort data=data;
     by category xdate;
run;

*- Determine first month within range where results exist -*;
proc means data=data nway noprint;
     class category;
     var xdate;
     output out=cutdates min=begdt max=enddt;
     where '01JAN2010'd<=xdate and resultn>0;
run;

data all_months;
     format begdt enddt date9.;
     merge all_months(in=a) cutdates(keep=category begdt enddt);
     by category;
     if enddt>=xdate>=begdt>. then cut=0;
run;

*- Bring dummy and actual data together -*;
data data;
     merge all_months(in=a) data;
     by category xdate;
     if a;
     if cut^=0 then resultn=.;
     else if resultn=. then resultn=0;
run;
    
*- Calculate mean and std dev -*;
proc means data=data nway noprint;
     class category;
     var resultn;
     output out=standard mean=mean std=std;
run;

*- Calculate deviations from the mean -*;
data final;
     merge data standard(keep=category mean std);
     by category;
    
     retain count;
     if first.category then count=0;
     count= count+1;
    
     if std^=0 and resultn^=. then deviations=(resultn-mean)/std;
     else if std=0 then deviations=0;

     if mean<=0 and std<=0 then delete;

     v_deviations=abs(ceil(deviations))+1;
run;

*- Determine the maximum value for the vertical axis -*;
proc means data=final nway noprint;
     var v_deviations;
     output out=vertaxis max=max;
run;

data _null_;
     set vertaxis;
     call symput('lvaxis',compress(put(max*-1,8.)));
     call symput('uvaxis',compress(put(max,8.)));
run;

*- Produce output -*;
goptions reset=all dev=png rotate=landscape gsfmode=replace htext=0.9 
         ftext='Albany AMT' hsize=9 vsize=5.5;

title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";

axis1 order=(1 to 73 by 6) value=("Jan 2010" "Jul 2010" "Jan 2011" "Jul 2011" "Jan 2012" "Jul 2012" 
      "Jan 2013" "Jul 2013" "Jan 2014" "Jul 2014" "Jan 2015" "Jul 2015" "Jan 2016") label=("ADMIT_DATE")
      minor=none
      offset=(0.5,1);

axis2 order=&lvaxis to &uvaxis label=(angle=90 "z score")
      minor=none
      offset=(0.5,.75);

%macro cat(cat,color);
    symbol1  c=&color line=1 v=NONE interpol=join;
    proc gplot data=final;
         title3 '#byval(category)';
         plot deviations*count / haxis=axis1 vaxis=axis2 nolegend vref=0 grid;
         by category;
         format category $cat.;
         where category="&cat";
    run;
    quit;
%mend cat;
%cat(cat=AV,color=red)
%cat(cat=ED,color=blue)
%cat(cat=EI,color=green)
%cat(cat=IP,color=brown)
%cat(cat=IS,color=bipb)
%cat(cat=OA,color=black)

*- Clear working directory -*;
%clean;

********************************************************************************;
* (10) TREND IN INSTITUTIONAL ENCOUNTERS BY DISCHARGE DATE AND ENCOUNTER TYPE
********************************************************************************;
%let _hdr=Chart IC;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create formats -*;
proc format;
     value $cat
        'EI'='EI (ED to IP Stay)'
        'IP'='IP (Inpatient Hospital Stay)'
        'IS'='IS (Non-acute Institutional Stay)'
        ;
run;

*- Create dataset containing all month/year values -*;
data all_months;
     format xdate date9.;
     length category $200;
     do category = "EI", "IP", "IS";
         do yr = 2010 to 2015;
            do mon = 1 to 12;
                xdate=mdy(mon,1,yr);
                output;
            end;
        end;
     end;
run;

proc sort data=all_months(keep=category xdate);
     by category xdate;
run;

*- Subset and create a month/year variable as a SAS date value -*;
data data;
     format xdate date9.;
     set dc_normal(where=(datamartid=%upcase("&dmid") and statistic="RECORD_N" and
         dc_name="ENC_L3_ENCTYPE_DDATE_YM" and category in ("EI" "IP" "IS")
         and cross_category^="NULL or missing"));

     if resultn=.t then resultn=0;

     xdate=mdy(input(scan(cross_category,2,'_'),2.),1,input(scan(cross_category,1,'_'),4.));
    
     keep category xdate resultn;
run;
    
proc sort data=data;
     by category xdate;
run;

*- Determine first month within range where results exist -*;
proc means data=data nway noprint;
     class category;
     var xdate;
     output out=cutdates min=begdt max=enddt;
     where '01JAN2010'd<=xdate and resultn>0;
run;

data all_months;
     format begdt enddt date9.;
     merge all_months(in=a) cutdates(keep=category begdt enddt);
     by category;
     if enddt>=xdate>=begdt>. then cut=0;
run;

*- Bring dummy and actual data together -*;
data data;
     merge all_months(in=a) data;
     by category xdate;
     if a;
     if cut^=0 then resultn=.;
     else if resultn=. then resultn=0;
run;
    
*- Calculate mean and std dev -*;
proc means data=data nway noprint;
     class category;
     var resultn;
     output out=standard mean=mean std=std;
run;

*- Calculate deviations from the mean -*;
data final;
     merge data standard(keep=category mean std);
     by category;
    
     retain count;
     if first.category then count=0;
     count= count+1;
    
     if std^=0 and resultn^=. then deviations=(resultn-mean)/std;
     else if std=0 then deviations=0;

     if mean<=0 and std<=0 then delete;

     v_deviations=abs(ceil(deviations))+1;
run;

*- Determine the maximum value for the vertical axis -*;
proc means data=final nway noprint;
     var v_deviations;
     output out=vertaxis max=max;
run;

data _null_;
     set vertaxis;
     call symput('lvaxis',compress(put(max*-1,8.)));
     call symput('uvaxis',compress(put(max,8.)));
run;

*- Produce output -*;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";

axis1 order=(1 to 73 by 6) value=("Jan 2010" "Jul 2010" "Jan 2011" "Jul 2011" "Jan 2012" "Jul 2012" 
      "Jan 2013" "Jul 2013" "Jan 2014" "Jul 2014" "Jan 2015" "Jul 2015" "Jan 2016") label=("DISCHARGE_DATE")
      minor=none
      offset=(0.5,1);

axis2 order=&lvaxis to &uvaxis label=(angle=90 "z score")
      minor=none
      offset=(0.5,.75);

%macro cat(cat,color);
    symbol1  c=&color line=1 v=NONE interpol=join;
    proc gplot data=final;
         title3 '#byval(category)';
         plot deviations*count / haxis=axis1 vaxis=axis2 nolegend vref=0 grid;
         by category;
         format category $cat.;
         where category="&cat";
    run;
    quit;
%mend cat;
%cat(cat=EI,color=green)
%cat(cat=IP,color=brown)
%cat(cat=IS,color=bipb)

*- Clear working directory -*;
%clean;

********************************************************************************;
* (11) DATE OBFUSCATION OR IMPUTATION
********************************************************************************;
%let _ftn=IG;
%let _hdr=Table IG;

*- Get titles and footnotes -;
%ttl_ftn;

*- Subset -*;
data final(keep=pg col:);
     length col1 col2 col4 $50 col3 $25;
     set dc_normal(where=(datamartid=%upcase("&dmid") and dc_name="XTBL_L3_METADATA"
         and variable in ("BIRTH_DATE_MGMT" "ENR_START_DATE_MGMT" "ENR_END_DATE_MGMT"
         "ADMIT_DATE_MGMT" "DISCHARGE_DATE_MGMT" "PX_DATE_MGMT" "MEASURE_DATE_MGMT")));

     col1="HARVEST";
     col2=variable;
     if resultc="01" then col3="No";
     else if resultc in ("02" "03" "04") then col3="Yes";
     else if resultc in ("NI" "UN" "OT" "NULL or missing") then col3="Missing, NI, UN or OT";
     else if resultc="Values outside of CDM specifications" then col3="Error";
     col4=dc_name;
     pg=1;
run;

*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 col2 col3 col4;

     define pg       /order noprint;
     define col1     /display flow "Table" style(header)=[just=left cellwidth=15%] style(column)=[just=left];
     define col2     /display flow "Field" style(header)=[just=left cellwidth=28%] style(column)=[just=left];
     define col3     /display flow "Date Obfuscation or Imputation" style(header)=[just=left cellwidth=30%] style(column)=[just=left];
     define col4     /display flow "Source table" style(header)=[just=left cellwidth=25%] style(column)=[just=left];
     compute col3;
        if col3="Yes" then call define(_col_, "style", "style=[color=red]");
     endcomp;

run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (12) PRIMARY KEY DEFINITIONS
********************************************************************************;
%let _ftn=STANDARD;
%let _hdr=Table IIA;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create table formats -*;
proc format;
     value pkeys
       1='PATID is unique'
       2='PATID + ENR_START_DATE+ENR_BASIS is unique'
       3='ENCOUNTERID is unique'
       4='DIAGNOSISID is unique'
       5='PROCEDURESID is unique'
       6='VITALID is unique'
       7='NETWORKID+DATAMARTID is unique'
        ;
run;

*- Macro for each EHR based data row -*;
%macro tbl(dcn=,ord=,var=);
    data tbl&ord(keep=ord col:);
         length col1-col4 $50;
         if _n_=1 then set dc_normal(where=(datamartid=%upcase("&dmid") and variable="&var"
                and statistic="DISTINCT_N" and dc_name="&dcn") rename=(resultn=distinct));
         set dc_normal(where=(datamartid=%upcase("&dmid") and variable="&var"
                and statistic="ALL_N" and dc_name="&dcn") rename=(resultn=all));

         ord=&ord;
         col1=strip(put(ord,tbl_row.));
         col2=strip(put(ord,pkeys.));
         if distinct=all then col3="Yes";
         else if distinct^=all then col3="No";
         col4=strip(dc_name);
    run;

    proc append base=tbl data=tbl&ord;
    run;
%mend;
%tbl(dcn=DEM_L3_N,ord=1,var=PATID)
%tbl(dcn=ENR_L3_N,ord=2,var=ENROLLID)
%tbl(dcn=ENC_L3_N,ord=3,var=ENCOUNTERID)
%tbl(dcn=DIA_L3_N,ord=4,var=DIAGNOSISID)
%tbl(dcn=PRO_L3_N,ord=5,var=PROCEDURESID)
%tbl(dcn=VIT_L3_N,ord=6,var=VITALID)

*- Unique structure for HARVEST data -*;
data harvest(keep=ord col:);
     length col1-col4 $50;
     set dc_normal(where=(datamartid=%upcase("&dmid") and variable="NETWORKID"
                 and dc_name="XTBL_L3_METADATA")) end=eof;
     if eof then do;
        ord=7;
        col1=strip(put(ord,tbl_row.));
        col2=strip(put(ord,pkeys.));
        if _n_=1 then col3="Yes";
        else col3="No";
        col4=strip(dc_name);
        output;
     end;
run;    

*- Bring everything together -*;
data final;
     set tbl harvest;
     by ord;
     pg=1;
run;
    
*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 col2 col3 col4;

     define pg       /order noprint;
     define col1     /display flow "Table" style(header)=[just=left cellwidth=17%] style(column)=[just=left];
     define col2     /display flow "CDM specifications for primary keys" style(header)=[just=left cellwidth=39%] style(column)=[just=left];
     define col3     /display flow "Table conforms to specifications?" style(header)=[just=left cellwidth=22%] style(column)=[just=left];
     define col4     /display flow "Source table" style(header)=[just=left cellwidth=19%] style(column)=[just=left];
     compute col3;
        if col3="No" then call define(_col_, "style", "style=[color=red]");
     endcomp;
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (13) VALUES OUTSIDE OF CDM SPECIFICATIONS
********************************************************************************;
%let _ftn=IIB;
%let _hdr=Table IIB;

*- Get titles and footnotes -;
%ttl_ftn;

*- Macro for each type of data row -*;
%macro stat(dcn=,ord=,ord2=,var=);
     if dc_name="&dcn" and variable="&var" and statistic="RECORD_N" and
                category="Values outside of CDM specifications" then do;
        ord=&ord;
        ord2=&ord2;
        col1=strip(put(ord,tbl_row.));
        col2=strip("&var");
        col3=put(input(strip(resultc),16.),comma16.);
        col4=strip(dc_name);
        output;
     end;
%mend stat;

%macro harvest(dcn=,ord=,ord2=,var=);
     if dc_name="&dcn" and variable="&var" and statistic="VALUE" then do;

        ord=&ord;
        ord2=&ord2;
        col1=strip(put(ord,tbl_row.));
        col2=strip("&var");
        if substr(resultc,1,21)="Values outside of CDM" then col3=">=1";
        else col3="0";
        col4=strip(dc_name);
        output;
     end;
%mend harvest;

%macro cross(dcn=,ord=,ord2=,var=);

    proc means data=dc_normal noprint nway;
         class dc_name;
         var resultn;
         output out=cross&ord sum=sum;
         where datamartid=%upcase("&dmid") and dc_name="&dcn" and variable="&var" 
             and statistic="RECORD_N" and category="Values outside of CDM specifications";
    run;
    
    data cross&ord(keep=ord: col:);
         length col1-col4 $50;
         set cross&ord;
             ord=&ord;
             ord2=&ord2;
             col1=strip(put(ord,tbl_row.));
             col2=strip("&var");
             col3=strip(put(sum,comma16.));
             col4=strip(dc_name);
    run;

    proc append base=cross data=cross&ord;
    run;

%mend cross;

*- Non-cross table queries -*;
data tbl(keep=ord: col:);
     length col1-col4 $50;
     set dc_normal(where=(datamartid=%upcase("&dmid")));

     %stat(dcn=DEM_L3_SEXDIST,ord=1,ord2=1,var=SEX)
     %stat(dcn=DEM_L3_HISPDIST,ord=1,ord2=2,var=HISPANIC)
     %stat(dcn=DEM_L3_RACEDIST,ord=1,ord2=3,var=RACE)
     %stat(dcn=ENR_L3_BASEDIST,ord=2,ord2=4,var=ENR_BASIS)
     %stat(dcn=ENC_L3_ENCTYPE,ord=3,ord2=5,var=ENC_TYPE)
     %stat(dcn=ENC_L3_DISDISP,ord=3,ord2=6,var=DISCHARGE_DISPOSITION)
     %stat(dcn=ENC_L3_DISSTAT,ord=3,ord2=7,var=DISCHARGE_STATUS)
     %stat(dcn=ENC_L3_DRG_TYPE,ord=3,ord2=8,var=DRG_TYPE)
     %stat(dcn=ENC_L3_ADMSRC,ord=3,ord2=9,var=ADMITTING_SOURCE)
     %stat(dcn=DIA_L3_ENCTYPE,ord=4,ord2=10,var=ENC_TYPE)
     %stat(dcn=DIA_L3_DXSOURCE,ord=4,ord2=12,var=DX_SOURCE)
     %stat(dcn=DIA_L3_PDX,ord=4,ord2=13,var=PDX)
     %stat(dcn=PRO_L3_ENCTYPE,ord=5,ord2=14,var=ENC_TYPE)
     %stat(dcn=PRO_L3_PXSOURCE,ord=5,ord2=16,var=PX_SOURCE)
     %stat(dcn=VIT_L3_VITAL_SOURCE,ord=6,ord2=17,var=VITAL_SOURCE)
     %stat(dcn=VIT_L3_BP_POSITION_TYPE,ord=6,ord2=18,var=BP_POSITION)
     %stat(dcn=VIT_L3_SMOKING,ord=6,ord2=19,var=SMOKING)
     %stat(dcn=VIT_L3_TOBACCO,ord=6,ord2=20,var=TOBACCO)
     %stat(dcn=VIT_L3_TOBACCO_TYPE,ord=6,ord2=21,var=TOBACCO_TYPE)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=22,var=DATAMART_PLATFORM)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=23,var=DATAMART_CLAIMS)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=24,var=DATAMART_EHR)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=25,var=BIRTH_DATE_MGMT)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=26,var=ENR_START_DATE_MGMT)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=27,var=ENR_END_DATE_MGMT)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=28,var=ADMIT_DATE_MGMT)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=29,var=DISCHARGE_DATE_MGMT)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=30,var=PX_DATE_MGMT)
run;

proc sort data=tbl;
     by ord ord2;
run;

*- Cross table queries -*;
%cross(dcn=DIA_L3_DXTYPE_DXSOURCE,ord=4,ord2=11,var=DX_TYPE)
%cross(dcn=PRO_L3_PXTYPE_ENCTYPE,ord=5,ord2=15,var=PX_TYPE)

proc sort data=cross;
     by ord ord2;
run;

*- Bring everything together -*;
data final;
     set tbl cross;
     by ord ord2;
     if col1^="HARVEST" then pg=1;
     else pg=2;
run;

*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 col2 col3 col4;
     where pg=1;

     define pg       /order noprint;
     define col1     /display flow "Table" style(header)=[just=left cellwidth=20%] style(column)=[just=left];
     define col2     /display flow "Field" style(header)=[just=left cellwidth=17%] style(column)=[just=left];
     define col3     /display flow "Number of records with values~outside of specifications" style(header)=[just=center cellwidth=27%] 
                                    style(column)=[just=center];
     define col4     /display flow "Source table" style(header)=[just=left cellwidth=35%] style(column)=[just=left];
     compute col3;
        if strip(col3)^="0" then call define(_col_, "style", "style=[color=red]");
     endcomp;
run;    

title1 justify=left "&_ttl1 (continued)";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 col2 col3 col4;
     where pg=2;

     define pg       /order noprint;
     define col1     /display flow "Table" style(header)=[just=left cellwidth=20%] style(column)=[just=left];
     define col2     /display flow "Field" style(header)=[just=left cellwidth=17%] style(column)=[just=left];
     define col3     /display flow "Number of records with values~outside of specifications" style(header)=[just=center cellwidth=27%]
                                    style(column)=[just=center];
     define col4     /display flow "Source table" style(header)=[just=left cellwidth=35%] style(column)=[just=left];
     compute col3;
        if strip(col3)^="0" then call define(_col_, "style", "style=[color=red]");
     endcomp;
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (14) NON-PERMISSABLE MISSING VALUES
********************************************************************************;
%let _ftn=IIC;
%let _hdr=Table IIC;

*- Get titles and footnotes -;
%ttl_ftn;

*- Macro for each type of data row -*;
%macro stat(dcn=,ord=,ord2=,cat=,var=,stat=);
     if dc_name="&dcn" and category="&cat" and variable="&var" and statistic="&stat" then do;
        ord=&ord;
        ord2=&ord2;
        col1=strip(put(ord,tbl_row.));
        col2=strip("&var");
        if resultn^=.t then col3=strip(put(resultn,comma16.));
        else col3=strip(put(resultn,threshold.));
        col4=strip(dc_name);
        output;
     end;
%mend stat;

%macro harvest(dcn=,ord=,ord2=,var=);
     if dc_name="&dcn" and variable="&var" and statistic="VALUE" then do;

        ord=&ord;
        ord2=&ord2;
        col1=strip(put(ord,tbl_row.));
        col2=strip("&var");
        if resultc^=" " then col3="0";
        else col3="1";
        col4=strip(dc_name);
        output;
     end;
%mend harvest;

%macro cross(dcn=,ord=,ord2=,var=);

    proc means data=dc_normal noprint nway;
         class dc_name;
         var resultn;
         output out=cross&ord sum=sum;
         where datamartid=%upcase("&dmid") and dc_name="&dcn" and cross_variable="&var" 
             and statistic="RECORD_N" and cross_category="NULL or missing";
    run;
    
    data cross&ord(keep=ord: col:);
         length col1-col4 $50;
         set cross&ord;
             ord=&ord;
             ord2=&ord2;
             col1=strip(put(ord,tbl_row.));
             col2=strip("&var");
             col3=strip(put(sum,comma16.));
             col4=strip(dc_name);
    run;

    proc append base=cross data=cross&ord;
    run;

%mend cross;

*- Non-cross table queries -*;
data tbl(keep=ord: col:);
     length col1-col4 $50;
     set dc_normal(where=(datamartid=%upcase("&dmid")));

     %stat(dcn=DEM_L3_N,ord=1,ord2=1,var=PATID,stat=NULL_N)
     %stat(dcn=ENR_L3_N,ord=2,ord2=2,var=PATID,stat=NULL_N)
     %stat(dcn=ENR_L3_N,ord=2,ord2=3,var=ENR_START_DATE,stat=NULL_N)
     %stat(dcn=ENR_L3_BASEDIST,ord=2,ord2=4,cat=NULL or missing,var=ENR_BASIS,stat=RECORD_N)
     %stat(dcn=ENC_L3_N,ord=3,ord2=5,var=PATID,stat=NULL_N)
     %stat(dcn=ENC_L3_N,ord=3,ord2=6,var=ENCOUNTERID,stat=NULL_N)
     %stat(dcn=ENC_L3_ADATE_Y,ord=3,ord2=7,cat=NULL or missing,var=ADMIT_DATE,stat=RECORD_N)
     %stat(dcn=ENC_L3_ENCTYPE,ord=3,ord2=8,cat=NULL or missing,var=ENC_TYPE,stat=RECORD_N)
     %stat(dcn=DIA_L3_N,ord=4,ord2=9,var=DIAGNOSISID,stat=NULL_N)
     %stat(dcn=DIA_L3_N,ord=4,ord2=10,var=PATID,stat=NULL_N)
     %stat(dcn=DIA_L3_N,ord=4,ord2=11,var=ENCOUNTERID,stat=NULL_N)
     %stat(dcn=DIA_L3_DX,ord=4,ord2=12,cat=NULL or missing,var=DX,stat=RECORD_N)
     %stat(dcn=DIA_L3_DXSOURCE,ord=4,ord2=14,cat=NULL or missing,var=DX_SOURCE,stat=RECORD_N)
     %stat(dcn=PRO_L3_N,ord=5,ord2=15,var=PROCEDURESID,stat=NULL_N)
     %stat(dcn=PRO_L3_N,ord=5,ord2=16,var=PATID,stat=NULL_N)
     %stat(dcn=PRO_L3_N,ord=5,ord2=17,var=ENCOUNTERID,stat=NULL_N)
     %stat(dcn=PRO_L3_PX,ord=5,ord2=18,cat=NULL or missing,var=PX,stat=RECORD_N)
     %stat(dcn=VIT_L3_N,ord=6,ord2=20,var=PATID,stat=NULL_N)
     %stat(dcn=VIT_L3_N,ord=6,ord2=21,var=VITALID,stat=NULL_N)
     %stat(dcn=VIT_L3_MDATE_Y,ord=6,ord2=22,cat=NULL or missing,var=MEASURE_DATE,stat=RECORD_N)
     %stat(dcn=VIT_L3_VITAL_SOURCE,ord=6,ord2=23,cat=NULL or missing,var=VITAL_SOURCE,stat=RECORD_N)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=24,var=NETWORKID)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=25,var=DATAMARTID)
run;

proc sort data=tbl;
     by ord ord2;
run;

*- Cross table queries -*;
%cross(dcn=DIA_L3_DXTYPE_ENCTYPE,ord=4,ord2=13,var=DX_TYPE)
%cross(dcn=PRO_L3_PXTYPE_ENCTYPE,ord=5,ord2=19,var=PX_TYPE)

proc sort data=cross;
     by ord ord2;
run;

*- Bring everything together -*;
data final;
     set tbl cross;
     by ord ord2;
     pg=1;
run;
    
*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 col2 col3 col4;

     define pg       /order noprint;
     define col1     /display flow "Table" style(header)=[just=left cellwidth=20%] style(column)=[just=left];
     define col2     /display flow "Field" style(header)=[just=left cellwidth=20%] style(column)=[just=left];
     define col3     /display flow "Number of records with missing values" style(header)=[just=center cellwidth=30%] style(column)=[just=center];
     define col4     /display flow "Source table" style(header)=[just=left cellwidth=28%] style(column)=[just=left];
     compute col3;
        if col3^="0" then call define(_col_, "style", "style=[color=red]");
     endcomp;
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (15) FUTURE DATES
********************************************************************************;
%let _ftn=IIIA;
%let _hdr=Table IIIA;

*- Get titles and footnotes -;
%ttl_ftn;

*- Macro for each type of data row -*;
%macro stat(dcn=,ord=,ord2=,tbl=,var=,stat=);
     if dc_name="&dcn" and table="&tbl" and variable="&var" and statistic="&stat" then do;
        nd=1;
        ord=&ord;
        ord2=&ord2;
        col1=strip(put(ord,tbl_row.));
        col2=strip("&var");
        if 0<resultn<=llc then resultn=.t;
        if resultn^=.t then col3=strip(put(resultn,comma16.));
        else col3=strip(put(resultn,threshold.));
        col4=" ";
        output;
     end;
%mend stat;

%macro denom(dcn=,ord=,ord2=,stat=);
     if dc_name="&dcn" and statistic="&stat" then do;
        nd=2;
        ord=&ord;
        ord2=&ord2;
        col3=" ";
        if resultn^=.t then col4=strip(put(resultn,comma16.));
        else col4=strip(put(resultn,threshold.));
        output;
     end;
%mend denom;

%macro harvest(dcn=,ord=,ord2=,var=);
     if dc_name="&dcn" and variable="&var" and statistic="VALUE" then do;
        nd=1;
        ord=&ord;
        ord2=&ord2;
        col1=strip(put(ord,tbl_row.));
        col2=strip("&var");
        if input(resultc,yymmdd10.)>today() then col3="1";
        else col3="0";
        col4=" ";
        output;
     end;
%mend harvest;

*- Non-cross table queries -*;
data tbl(keep=ord: col: dc_name resultn nd);
     length col1-col4 $50;
     if _n_=1 then set dc_normal(where=(datamartid=%upcase("&dmid" and dc_name="XTBL_L3_METADATA" and variable="LOW_CELL_CNT")) rename=(resultn=llc));
     set dc_normal(where=(datamartid=%upcase("&dmid")));

     %stat(dcn=XTBL_L3_DATES,ord=1,ord2=1,tbl=DEMOGRAPHIC,var=BIRTH_DATE,stat=FUTURE_DT_N)
     %denom(dcn=DEM_L3_AGEYRSDIST1,ord=1,ord2=1,stat=N)
     %stat(dcn=XTBL_L3_DATES,ord=2,ord2=2,tbl=ENROLLMENT,var=ENR_START_DATE,stat=FUTURE_DT_N)
     %denom(dcn=ENR_L3_DIST_START,ord=2,ord2=2,stat=N)
     %stat(dcn=XTBL_L3_DATES,ord=2,ord2=3,tbl=ENROLLMENT,var=ENR_END_DATE,stat=FUTURE_DT_N)
     %denom(dcn=ENR_L3_DIST_END,ord=2,ord2=3,stat=N)
     %stat(dcn=XTBL_L3_DATES,ord=3,ord2=4,tbl=ENCOUNTER,var=ADMIT_DATE,stat=FUTURE_DT_N)
     %stat(dcn=XTBL_L3_DATES,ord=3,ord2=5,tbl=ENCOUNTER,var=DISCHARGE_DATE,stat=FUTURE_DT_N)
     %stat(dcn=XTBL_L3_DATES,ord=4,ord2=6,tbl=DIAGNOSIS,var=ADMIT_DATE,stat=FUTURE_DT_N)
     %stat(dcn=XTBL_L3_DATES,ord=5,ord2=7,tbl=PROCEDURES,var=ADMIT_DATE,stat=FUTURE_DT_N)
     %stat(dcn=XTBL_L3_DATES,ord=5,ord2=8,tbl=PROCEDURES,var=PX_DATE,stat=FUTURE_DT_N)
     %stat(dcn=XTBL_L3_DATES,ord=6,ord2=9,tbl=VITAL,var=MEASURE_DATE,stat=FUTURE_DT_N)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=10,var=REFRESH_DEMOGRAPHIC_DATE)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=11,var=REFRESH_ENROLLMENT_DATE)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=12,var=REFRESH_ENCOUNTER_DATE)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=13,var=REFRESH_DIAGNOSIS_DATE)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=14,var=REFRESH_PROCEDURES_DATE)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=15,var=REFRESH_VITAL_DATE)
     %harvest(dcn=XTBL_L3_METADATA,ord=7,ord2=16,var=REFRESH_MAX)
run;

proc sort data=tbl;
     by ord ord2;
run;

*- Denominators for rows requiring summation -*;
data date_y;
     set dc_normal;
     if scan(dc_name,4,"_")="Y" and statistic="RECORD_N" and category^="NULL or missing";

     * flag BT records *;
     if resultn=.t then do;
        bt_flag="*";
        resultn=.;
     end;
     if resultn=. then resultn=0;

     keep dc_name resultn bt_flag;
run;

proc means data=date_y nway missing noprint;
     class dc_name bt_flag;
     var resultn;
     output out=xdenom sum=denom;
run;

data xdenom;
     length col4 $50;
     merge xdenom(rename=(bt_flag=flag) where=(flag=" "))
           xdenom(in=bt drop=denom where=(bt_flag="*"))
     ;
     by dc_name;

     col4=strip(put(denom,comma16.))||strip(bt_flag);
     if dc_name="DIA_L3_ADATE_Y" then do; ord=4; ord2=6; end;
     else if dc_name="ENC_L3_ADATE_Y" then do; ord=3; ord2=4; end;
     else if dc_name="ENC_L3_DDATE_Y" then do; ord=3; ord2=5; end;
     else if dc_name="PRO_L3_ADATE_Y" then do; ord=5; ord2=7; end;
     else if dc_name="PRO_L3_PXDATE_Y" then do; ord=5; ord2=8; end;
     else if dc_name="VIT_L3_MDATE_Y" then do; ord=6; ord2=9; end;
run;

proc sort data=xdenom;
     by ord ord2;
run;

*- Bring everything together -*;
data final(drop=col3);
     merge tbl(where=(nd=1) drop=col4)
           tbl(where=(nd=2) keep=ord: nd col4 resultn dc_name rename=(resultn=denom dc_name=den_name))
           xdenom(keep=ord: col4 denom dc_name rename=(dc_name=den_name))
     ;
     by ord ord2;

     col3n=input(col3,comma16.);
     if denom>0 and resultn>=0 then col5=strip(put((resultn/denom)*100,6.2));
     if den_name^=" " then col6=strip(dc_name)||"; "||strip(den_name);
     else if den_name=" " then col6=strip(dc_name);
     pg=1;
run;

*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column col3n ord pg col1 col2 
            ("Records with future dates~____________________________________________" col3 col4 col5) 
            col6;

     define col3n    /display noprint;
     define ord      /display noprint;
     define pg       /order noprint;
     define col1     /display flow "Table" style(header)=[just=left cellwidth=12%] style(column)=[just=left];
     define col2     /display flow "Field" style(header)=[just=left cellwidth=22%] style(column)=[just=left];
     define col3     /computed format=comma16. "Numerator" style(header)=[just=center cellwidth=12%] style(column)=[just=center];
     define col4     /display flow "Denominator" style(header)=[just=center cellwidth=12%] style(column)=[just=center];
     define col5     /display flow "%" style(header)=[just=center cellwidth=8%] style(column)=[just=center];
     define col6     /display flow "Source table(s)" style(header)=[just=left cellwidth=32%] style(column)=[just=left];
     compute col3;
        if ord=7 and col3n>0 then do;
            col3=col3n;
            call define(_col_, "style", "style=[color=red]");
        end;
        else do;
            col3=col3n;
        end;
     endcomp;
     compute col5;
        if input(col5,5.2)>5.00 then call define(_col_, "style", "style=[color=red]");
     endcomp;
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (16) RECORDS WITH EXTREME VALUES
********************************************************************************;
%let _ftn=IIIB;
%let _hdr=Table IIIB;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create table formats -*;
proc format;
     value field
        1='AGE (derived from BIRTH_DATE)'
        2='HT'
        3='WT'
        4='DIASTOLIC'
        5='SYSTOLIC'
        ;

     value low
        1='<0 yrs.'
        2='<0 inches'
        3='<0 lbs.'
        4='<40 mgHg'
        5='<40 mgHg'
        ;

     value high
        1='>110 yrs.'
        2='>=95 inches'
        3='>350 lbs.'
        4='>120 mgHg'
        5='>210 mgHg'
        ;
run;

*- Macro for each type of data row -*;
%macro stat(dcn=,ord=,bound=,cat=,stat=);
     if dc_name="&dcn" and category="&cat" and statistic="&stat" then do;
        ord=&ord;
        bound="&bound";
        col1=strip(table);
        %if &stat=RECORD_N %then %do;
            if resultn^=.t then result=strip(put(resultn,comma16.));
            else result=strip(put(resultn,threshold.));
        %end;
        %else %if &stat=RECORD_PCT %then %do;
            if resultn^=. then result=strip(put(resultn,5.1));
        %end;
        col10=strip(dc_name);
        output;
     end;
%mend stat;

*- Non-cross table queries -*;
data tbl(keep=ord bound statistic result col:);
     length col1 col10 result $50;
     set dc_normal(where=(datamartid=%upcase("&dmid")));

     %stat(dcn=DEM_L3_AGEYRSDIST2,ord=1,bound=L,cat=<0 yrs,stat=RECORD_N)
     %stat(dcn=DEM_L3_AGEYRSDIST2,ord=1,bound=L,cat=<0 yrs,stat=RECORD_PCT)
     %stat(dcn=DEM_L3_AGEYRSDIST2,ord=1,bound=H,cat=>110 yrs,stat=RECORD_N)
     %stat(dcn=DEM_L3_AGEYRSDIST2,ord=1,bound=H,cat=>110 yrs,stat=RECORD_PCT)

     %stat(dcn=VIT_L3_HT,ord=2,bound=L,cat=<0,stat=RECORD_N)
     %stat(dcn=VIT_L3_HT,ord=2,bound=L,cat=<0,stat=RECORD_PCT)
     %stat(dcn=VIT_L3_HT,ord=2,bound=H,cat=>=95,stat=RECORD_N)
     %stat(dcn=VIT_L3_HT,ord=2,bound=H,cat=>=95,stat=RECORD_PCT)
    
     %stat(dcn=VIT_L3_WT,ord=3,bound=L,cat=<0,stat=RECORD_N)
     %stat(dcn=VIT_L3_WT,ord=3,bound=L,cat=<0,stat=RECORD_PCT)
     %stat(dcn=VIT_L3_WT,ord=3,bound=H,cat=>350,stat=RECORD_N)
     %stat(dcn=VIT_L3_WT,ord=3,bound=H,cat=>350,stat=RECORD_PCT)
    
     %stat(dcn=VIT_L3_DIASTOLIC,ord=4,bound=L,cat=<40,stat=RECORD_N)
     %stat(dcn=VIT_L3_DIASTOLIC,ord=4,bound=L,cat=<40,stat=RECORD_PCT)
     %stat(dcn=VIT_L3_DIASTOLIC,ord=4,bound=H,cat=>120,stat=RECORD_N)
     %stat(dcn=VIT_L3_DIASTOLIC,ord=4,bound=H,cat=>120,stat=RECORD_PCT)
    
     %stat(dcn=VIT_L3_SYSTOLIC,ord=5,bound=L,cat=<40,stat=RECORD_N)
     %stat(dcn=VIT_L3_SYSTOLIC,ord=5,bound=L,cat=<40,stat=RECORD_PCT)
     %stat(dcn=VIT_L3_SYSTOLIC,ord=5,bound=H,cat=>210,stat=RECORD_N)
     %stat(dcn=VIT_L3_SYSTOLIC,ord=5,bound=H,cat=>210,stat=RECORD_PCT)
run;

proc sort data=tbl;
     by ord;
run;

*- Denominators for rows requiring summation -*;
data denom;
     set dc_normal;
     if statistic="RECORD_N" and category^="NULL or missing" and 
        dc_name in ("DEM_L3_AGEYRSDIST2" "VIT_L3_HT" "VIT_L3_WT" "VIT_L3_DIASTOLIC" "VIT_L3_SYSTOLIC");

     * flag BT records *;
     if resultn=.t then do;
        bt_flag="*";
        resultn=.;
     end;
     if resultn=. then resultn=0;

     keep dc_name resultn bt_flag;
run;

proc means data=denom nway missing noprint;
     class dc_name bt_flag;
     var resultn;
     output out=xdenom sum=denom;
run;

data xdenom;
     length col5 $50;
     merge xdenom(rename=(bt_flag=flag) where=(flag=" "))
           xdenom(in=bt drop=denom where=(bt_flag="*"))
     ;
     by dc_name;

     col5=strip(put(denom,comma16.))||strip(bt_flag);
     if dc_name="DEM_L3_AGEYRSDIST2" then ord=1;
     else if dc_name="VIT_L3_HT" then ord=2;
     else if dc_name="VIT_L3_WT" then ord=3;
     else if dc_name="VIT_L3_DIASTOLIC" then ord=4;
     else if dc_name="VIT_L3_SYSTOLIC" then ord=5;
run;

proc sort data=xdenom;
     by ord;
run;

*- Bring everything together -*;
data final(keep=pg ord col:);
     length col1-col10 $50;
     merge tbl(where=(statistic="RECORD_N" and bound="L") rename=(result=col6))
           tbl(where=(statistic="RECORD_PCT" and bound="L") rename=(result=col7))
           tbl(where=(statistic="RECORD_N" and bound="H") rename=(result=col8))
           tbl(where=(statistic="RECORD_PCT" and bound="H") rename=(result=col9))
           xdenom
     ;
     by ord;
        
     col2=strip(put(ord,field.));
     col3=strip(put(ord,low.));
     col4=strip(put(ord,high.));

     pg=1;
run;

*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column pg col1 col2 ("Data Check~ Parameters~__________________________" col3 col4) col5 
               ("Records with values in the lowest category~______________________" col6 col7)
               ("Records with values in the highest category~______________________" col8 col9) col10;

     define pg       /order noprint;
     define col1     /display flow "Table" style(header)=[just=left cellwidth=12%] style(column)=[just=left];
     define col2     /display flow "Field" style(header)=[just=left cellwidth=11%] style(column)=[just=left];
     define col3     /display flow "Low" style(header)=[just=center cellwidth=9%] style(column)=[just=center];
     define col4     /display flow "High" style(header)=[just=center cellwidth=9%] style(column)=[just=center];
     define col5     /display flow "Records" style(header)=[just=center cellwidth=9%] style(column)=[just=center];
     define col6     /display flow "N" style(header)=[just=center cellwidth=10%] style(column)=[just=center];
     define col7     /display flow "%" style(header)=[just=center cellwidth=5%] style(column)=[just=center];
     define col8     /display flow "N" style(header)=[just=center cellwidth=10%] style(column)=[just=center];
     define col9     /display flow "%" style(header)=[just=center cellwidth=5%] style(column)=[just=center];
     define col10    /display flow "Source table" style(header)=[just=left cellwidth=17%] style(column)=[just=left];
     compute col7;
        if input(col7,8.2)>20.00 then call define(_col_, "style", "style=[color=red]");
     endcomp;
     compute col9;
        if input(col9,8.2)>20.00 then call define(_col_, "style", "style=[color=red]");
     endcomp;
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (17) DIAGNOSIS RECORDS PER ENCOUNTER, OVERALL AND BY ENCOUNTER TYPE
********************************************************************************;
%let _ftn=IVA;
%let _hdr=Table IVA;

*- Get titles and footnotes -;
%ttl_ftn;

*- Subset and Re-categorize encounter type -*;
data data;
     length cat $50;
     set dc_normal(where=(datamartid=%upcase("&dmid") and statistic="RECORD_N"
         and dc_name in ("DIA_L3_ENCTYPE" "ENC_L3_ENCTYPE")
         and category^="Values outside of CDM specifications"));

     * re-categorize encounter type *;
     if category in ("NI" "UN" "OT" "NULL or missing") then cat="Missing, NI, UN or OT";
     else cat=category;

     * flag BT records *;
     if resultn=.t and statistic="RECORD_N" then do;
        bt_flag="*";
        resultn=.;
     end;
     if resultn=. then resultn=0;
     output;
     cat="TOTAL";
     output;
     keep dc_name cat resultn bt_flag;
run;

*- Summarize counts on new encounter type -*;
proc means data=data missing nway noprint;
     class dc_name cat bt_flag;
     var resultn;
     output out=stats sum=sum;
run;

data stats;
     merge stats(rename=(bt_flag=flag) where=(flag=" "))
           stats(in=bt drop=sum where=(bt_flag="*"))
     ;
     by dc_name cat;
run;

proc sort;
     by cat;
run;

*- Bring everything together -*;
data final(keep=pg ord col: perc thresholdflag);
     length col1-col3 col5 $50;
     merge stats(where=(scan(dc_name,1,'_')="DIA") rename=(sum=diagnosis bt_flag=bt_dia))
           stats(where=(scan(dc_name,1,'_')="ENC") rename=(sum=encounter bt_flag=bt_enc))
     ;
     by cat;

     ord=put(cat,$svar.);
     col1=strip(put(cat,$etype.));
     if diagnosis=. and bt_dia="*" then col2=strip(put(.t,threshold.));
     else col2=strip(put(diagnosis,comma16.))||strip(bt_dia);
     if encounter=. and bt_enc="*" then col3=strip(put(.t,threshold.));
     else col3=strip(put(encounter,comma16.))||strip(bt_enc);
     if encounter>0 then perc=diagnosis/encounter;
     col5=strip("DIA_L3_ENCTYPE; ENC_L3_ENCTYPE");

     pg=1;
     if cat in ('AV' 'ED' 'IP') and perc<1.00 then thresholdflag=1;
run;

proc sort;
     by ord;
run;

*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column thresholdflag perc pg col1 col2 col3 col4 col5;

     define thresholdflag /display noprint;
     define perc     /display noprint;
     define pg       /order noprint;
     define col1     /display flow "Encounter Type" style(header)=[just=left cellwidth=25%] style(column)=[just=left];
     define col2     /display flow "DIAGNOSIS~records" style(header)=[just=center cellwidth=15%] style(column)=[just=center];
     define col3     /display flow "ENCOUNTER~records" style(header)=[just=center cellwidth=15%] style(column)=[just=center];
     define col4     /computed format=8.2 "Diagnosis Per Encounter" style(header)=[just=center cellwidth=15%] style(column)=[just=center];
     define col5     /display flow "Source table" style(header)=[just=left cellwidth=28%] style(column)=[just=left];
     compute col4;
        if thresholdflag=1 then do;
           col4=perc;
           call define(_col_, "style", "style=[color=red]");
        end;
        else do;
           col4=perc;
        end;
     endcomp;
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (18) DIAGNOSIS RECORDS PER ENCOUNTER BY ADMIT DATE AND BY ENCOUNTER TYPE
********************************************************************************;
%let _hdr=Chart IVA;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create dataset containing all month/year values -*;
data all_months;
     format xdate date9.;
     length category $200;
     do category = "ED", "EI", "IP", "IS", "OA", "AV";
         do yr = 2010 to 2015;
            do mon = 1 to 12;
                xdate=mdy(mon,1,yr);
                output;
            end;
        end;
     end;
run;

proc sort data=all_months(keep=category xdate);
     by category xdate;
run;

*- Subset and create a month/year variable as a SAS date value -*;
data data;
     format xdate date9.;
     set dc_normal(where=(datamartid=%upcase("&dmid") and statistic="RECORD_N" and
         dc_name in ("DIA_L3_ENCTYPE_ADATE_YM" "ENC_L3_ENCTYPE_ADATE_YM") and
         category in ("ED" "EI" "IP" "IS" "OA" "AV") and cross_category^="NULL or missing"));

     if resultn=.t then resultn=0;
     xdate=mdy(input(scan(cross_category,2,'_'),2.),1,input(scan(cross_category,1,'_'),4.));
    
     keep dc_name category xdate resultn;
run;
    
proc sort data=data;
     by category xdate;
run;

*- Bring dummy and actual data together -*;
data data;
     merge all_months(in=a) 
           data( where=(dc_name="DIA_L3_ENCTYPE_ADATE_YM") rename=(resultn=diagnosis))
           data( where=(dc_name="ENC_L3_ENCTYPE_ADATE_YM") rename=(resultn=encounter))
     ;
     by category xdate;
     if a;
     if diagnosis<=0 or encounter<=0 then rate=.;
     else rate=diagnosis/encounter;
run;

*- Determine the maximum value for the vertical axis -*;
proc means data=data nway noprint;
     var rate;
     output out=vertaxis max=max;
run;

data _null_;
     set vertaxis;
     if max>=250 then do;
        vertaxis=max-mod(max,25)+25;
        tick=25;
     end;
     else if max>=100 then do;
        vertaxis=max-mod(max,10)+10;
        tick=10;
     end;
     else if max>=10 then do;
        vertaxis=max-mod(max,5)+5;
        tick=5;
     end;
     else if max<10 then do;
        vertaxis=10;
        tick=1;
     end;
     call symput('vertaxis',compress(put(vertaxis,8.)));
     call symput('bytick',compress(put(tick,8.)));
run;

*- Create a count variable to represent each month -*;
data final;
     set data;
     by category;
    
     retain count;
     if first.category then count=0;
     count= count+1;
run;
            
*- Produce output -*;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";

symbol1  c=red line=1 v=NONE interpol=join;
symbol2  c=blue line=1 v=NONE interpol=join;
symbol3  c=green line=1 v=NONE interpol=join;
symbol4  c=brown line=1 v=NONE interpol=join;
symbol5  c=bipb line=1 v=NONE interpol=join;
symbol6  c=black line=1 v=NONE interpol=join;

axis1 order=(1 to 73 by 6) value=("Jan 2010" "Jul 2010" "Jan 2011" "Jul 2011" "Jan 2012" "Jul 2012" 
      "Jan 2013" "Jul 2013" "Jan 2014" "Jul 2014" "Jan 2015" "Jul 2015" "Jan 2016") label=("ADMIT_DATE" h=1.5)
      minor=none
      offset=(0.5,1);

axis2 order=0 to &vertaxis by &bytick label=(angle=90 "Diagnosis Records per Encounter" h=1.5)
      minor=(n=1)
      offset=(0.5,.75);

legend1 label=none noframe;

proc gplot data=final;
     plot rate*count=category / haxis=axis1 vaxis=axis2 legend=legend1 vref=0 grid;
run;
quit;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (19) DIAGNOSIS RECORDS PER ENCOUNTER, OVERALL AND BY ENCOUNTER TYPE
********************************************************************************;
%let _ftn=IVB;
%let _hdr=Table IVB;

*- Get titles and footnotes -;
%ttl_ftn;

*- Subset and Re-categorize encounter type -*;
data data;
     length cat $50;
     set dc_normal(where=(datamartid=%upcase("&dmid") and statistic="RECORD_N"
         and dc_name in ("PRO_L3_ENCTYPE" "ENC_L3_ENCTYPE")
         and category^="Values outside of CDM specifications"));

     * re-categorize encounter type *;
     if category in ("NI" "UN" "OT" "NULL or missing") then cat="Missing, NI, UN or OT";
     else cat=category;

     * flag BT records *;
     if resultn=.t and statistic="RECORD_N" then do;
        bt_flag="*";
        resultn=.;
     end;
     if resultn=. then resultn=0;
     output;
     cat="TOTAL";
     output;
     keep dc_name cat resultn bt_flag;
run;

*- Summarize counts on new encounter type -*;
proc means data=data missing nway noprint;
     class dc_name cat bt_flag;
     var resultn;
     output out=stats sum=sum;
run;

data stats;
     merge stats(rename=(bt_flag=flag) where=(flag=" "))
           stats(in=bt drop=sum where=(bt_flag="*"))
     ;
     by dc_name cat;
run;

proc sort;
     by cat;
run;

*- Bring everything together -*;
data final(keep=pg ord col: perc thresholdflag);
     length col1-col3 col5 $50;
     merge stats(where=(scan(dc_name,1,'_')="PRO") rename=(sum=procedure bt_flag=bt_pro))
           stats(where=(scan(dc_name,1,'_')="ENC") rename=(sum=encounter bt_flag=bt_enc))
     ;
     by cat;

     ord=put(cat,$svar.);
     col1=strip(put(cat,$etype.));
     if procedure=. and bt_pro="*" then col2=strip(put(.t,threshold.));
     else col2=strip(put(procedure,comma16.))||strip(bt_pro);
     if encounter=. and bt_enc="*" then col3=strip(put(.t,threshold.));
     else col3=strip(put(encounter,comma16.))||strip(bt_enc);
     if encounter>0 then perc=procedure/encounter;
     col5=strip("PRO_L3_ENCTYPE; ENC_L3_ENCTYPE");

     pg=1;
     if cat in ('AV' 'ED' 'IP') and perc<1.00 then thresholdflag=1;
run;

proc sort;
     by ord;
run;
    
*- Produce output -*;
ods listing close;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column thresholdflag perc pg col1 col2 col3 col4 col5;

     define thresholdflag /display noprint;
     define perc     /display noprint;
     define pg       /order noprint;
     define col1     /display flow "Encounter Type" style(header)=[just=left cellwidth=25%] style(column)=[just=left];
     define col2     /display flow "PROCEDURES~records" style(header)=[just=center cellwidth=15%] style(column)=[just=center];
     define col3     /display flow "ENCOUNTER~records" style(header)=[just=center cellwidth=15%] style(column)=[just=center];
     define col4     /computed format=8.2 "Procedures Per Encounter" style(header)=[just=center cellwidth=15%] style(column)=[just=center];
     define col5     /display flow "Source table" style(header)=[just=left cellwidth=28%] style(column)=[just=left];
     compute col4;
        if thresholdflag=1 then do;
           col4=perc;
           call define(_col_, "style", "style=[color=red]");
        end;
        else do;
           col4=perc;
        end;
     endcomp;
run;    

ods listing;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (20) PROCEDURE RECORDS PER ENCOUNTER BY ADMIT DATE AND BY ENCOUNTER TYPE
********************************************************************************;
%let _hdr=Chart IVB;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create dataset containing all month/year values -*;
data all_months;
     format xdate date9.;
     length category $200;
     do category = "ED", "EI", "IP", "IS", "OA", "AV";
         do yr = 2010 to 2015;
            do mon = 1 to 12;
                xdate=mdy(mon,1,yr);
                output;
            end;
        end;
     end;
run;

proc sort data=all_months(keep=category xdate);
     by category xdate;
run;

*- Subset and create a month/year variable as a SAS date value -*;
data data;
     format xdate date9.;
     set dc_normal(where=(datamartid=%upcase("&dmid") and statistic="RECORD_N" and
         dc_name in ("PRO_L3_ENCTYPE_ADATE_YM" "ENC_L3_ENCTYPE_ADATE_YM") and
         category in ("ED" "EI" "IP" "IS" "OA" "AV") and cross_category^="NULL or missing"));

     if resultn=.t then resultn=0;
     xdate=mdy(input(scan(cross_category,2,'_'),2.),1,input(scan(cross_category,1,'_'),4.));
    
     keep dc_name category xdate resultn;
run;
    
proc sort data=data;
     by category xdate;
run;

*- Bring dummy and actual data together -*;
data data;
     merge all_months(in=a) 
           data( where=(dc_name="PRO_L3_ENCTYPE_ADATE_YM") rename=(resultn=procedure))
           data( where=(dc_name="ENC_L3_ENCTYPE_ADATE_YM") rename=(resultn=encounter))
     ;
     by category xdate;
     if a;
     if procedure<=0 or encounter<=0 then rate=.;
     else rate=procedure/encounter;
run;
    
*- Determine the maximum value for the vertical axis -*;
proc means data=data nway noprint;
     var rate;
     output out=vertaxis max=max;
run;

data _null_;
     set vertaxis;
     if max>=250 then do;
        vertaxis=max-mod(max,25)+25;
        tick=25;
     end;
     else if max>=100 then do;
        vertaxis=max-mod(max,10)+10;
        tick=10;
     end;
     else if max>=10 then do;
        vertaxis=max-mod(max,5)+5;
        tick=5;
     end;
     else if max<10 then do;
        vertaxis=10;
        tick=1;
     end;
     call symput('vertaxis',compress(put(vertaxis,8.)));
     call symput('bytick',compress(put(tick,8.)));
run;

*- Create a count variable to represent each month -*;
data final;
     set data;
     by category;
    
     retain count;
     if first.category then count=0;
     count= count+1;
run;
            
*- Produce output -*;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";

symbol1  c=red line=1 v=NONE interpol=join;
symbol2  c=blue line=1 v=NONE interpol=join;
symbol3  c=green line=1 v=NONE interpol=join;
symbol4  c=brown line=1 v=NONE interpol=join;
symbol5  c=bipb line=1 v=NONE interpol=join;
symbol6  c=black line=1 v=NONE interpol=join;

axis1 order=(1 to 73 by 6) value=("Jan 2010" "Jul 2010" "Jan 2011" "Jul 2011" "Jan 2012" "Jul 2012" 
      "Jan 2013" "Jul 2013" "Jan 2014" "Jul 2014" "Jan 2015" "Jul 2015" "Jan 2016") label=("ADMIT_DATE" h=1.5)
      minor=none
      offset=(0.5,1);

axis2 order=0 to &vertaxis by &bytick label=(angle=90 "Procedure Records per Encounter" h=1.5)
      minor=(n=1)
      offset=(0.5,.75);

legend1 label=none noframe;

proc gplot data=final;
     plot rate*count=category / haxis=axis1 vaxis=axis2 legend=legend1 vref=0 grid;
run;
quit;

*- Clear working directory -*;
%clean;

********************************************************************************;
* (21) MISSING OR UNKNOWN VALUES
********************************************************************************;
%let _ftn=IVC;
%let _hdr=Table IVC;

*- Get titles and footnotes -;
%ttl_ftn;

*- Create table formats -*;
proc format;
     value $field
        "BIRTH_DATE"="01"
        "SEX"="02"
        "HISPANIC"="03"
        "RACE"="04"
        "ENR_END_DATE"="05"
        "DISCHARGE_DATE"="06"
        "ENC_TYPE"="07"
        "PROVIDERID"="08"
        "DISCHARGE_DISPOSITION"="09"
        "DISCHARGE_STATUS"="10"
        "DRG"="11"
        "ADMITTING_SOURCE"="12"
        "DX_TYPE"="13"
        "DX_SOURCE"="14"
        "PDX"="15"
        "PX_DATE"="16"
        "PX_TYPE"="17"
        "PX_SOURCE"="18"
        "VITAL_SOURCE"="19"
        ;
run;

*- Denominators -*;
data denominators;
     set dc_normal(where=(datamartid=%upcase("&dmid") and 
                (scan(dc_name,3,'_')="N" and statistic in ("ALL_N" "NULL_N") and variable in ("PATID")) or
                (dc_name in ("ENC_L3_ENCTYPE_DDATE_YM" "ENC_L3_ENCTYPE_DISDISP" "ENC_L3_ENCTYPE_DISSTAT" 
                             "ENC_L3_ENCTYPE_DRG" "ENC_L3_ENCTYPE_ADMRSC" "DIA_L3_PDX_ENCTYPE") 
                and category in ("IP" "IS" "EI") and statistic="RECORD_N")));

     * flag BT records *;
     if resultn=.t and statistic="RECORD_N" then do;
        bt_flag="*";
        resultn=.;
     end;
     if resultn=. then resultn=0;

     keep table dc_name resultn bt_flag;
run;

proc means data=denominators nway missing noprint;
     class table dc_name bt_flag;
     var resultn;
     output out=denom sum=denom;
run;

data denom;
     length mvar $50;
     merge denom(rename=(bt_flag=flag) where=(flag=" "))
           denom(in=bt drop=denom where=(bt_flag="*"))
     ;
     by table dc_name;

     if dc_name in ("ENC_L3_ENCTYPE_DDATE_YM" "ENC_L3_ENCTYPE_DISDISP" "ENC_L3_ENCTYPE_DISSTAT" 
        "ENC_L3_ENCTYPE_DRG" "ENC_L3_ENCTYPE_ADMRSC" "DIA_L3_PDX_ENCTYPE") then mvar=dc_name;
     else mvar=" ";
run;

proc sort data=denom;
     by table mvar;
run;

*- Numerators -*;
data numerators;
     set dc_normal(where=(datamartid=%upcase("&dmid")));
     if (dc_name in ("DEM_L3_AGEYRSDIST1" "ENR_L3_DIST_END" ) and statistic="NULL or missing") or
        (dc_name in ("DEM_L3_SEXDIST" "DEM_L3_HISPDIST" "DEM_L3_RACEDIST" "ENC_L3_ENCTYPE" 
                     "DIA_L3_DXSOURCE" "PRO_L3_PXDATE_Y" "PRO_L3_PXSOURCE" "VIT_L3_VITAL_SOURCE" 
                     "PRO_L3_PXTYPE_ENCTYPE") and category in ("NULL or missing" "NI" "UN" "OT") and statistic="RECORD_N") or
        (dc_name in ("ENC_L3_ENCTYPE_DDATE_YM" "ENC_L3_ENCTYPE_DISDISP" "ENC_L3_ENCTYPE_DISSTAT" 
                     "ENC_L3_ENCTYPE_DRG" "ENC_L3_ENCTYPE_ADMRSC" "DIA_L3_PDX_ENCTYPE")  and category in ("IP" "IS" "EI") and 
                     cross_category in ("NULL or missing" "NI" "UN" "OT") and statistic="RECORD_N") or
        (dc_name in ("DIA_L3_DXTYPE_DXSOURCE") and category in ("NULL or missing" "NI" "UN" "OT") and statistic="RECORD_N") or
        (dc_name in ("PRO_L3_PXTYPE_ENCTYPE") and cross_category in ("NULL or missing" "NI" "UN" "OT") and statistic="RECORD_N") or
        (dc_name in ("ENC_L3_N") and statistic="NULL_N" and variable="PROVIDERID")
        ;

     if dc_name in ("ENC_L3_ENCTYPE_DDATE_YM" "ENC_L3_ENCTYPE_DISDISP" "ENC_L3_ENCTYPE_DISSTAT" 
                    "ENC_L3_ENCTYPE_DRG" "ENC_L3_ENCTYPE_ADMRSC" "DIA_L3_PDX_ENCTYPE" "PRO_L3_PXTYPE_ENCTYPE") then var=cross_variable;
     else if dc_name="DEM_L3_AGEYRSDIST1" then var="BIRTH_DATE";
     else if dc_name="ENR_L3_DIST_END" then var="ENR_END_DATE";
     else var=variable;

     * flag BT records *;
     if resultn=.t and statistic="RECORD_N" then do;
        bt_flag="*";
        resultn=.;
     end;
     if resultn=. then resultn=0;

     keep table resultn dc_name var bt_flag;
run;

*- Recalculate count and percent -*;
proc means data=numerators nway missing noprint;
     class table dc_name var bt_flag;
     var resultn;
     output out=num sum=num;
run;

data num;
     length mvar $50;
     merge num(rename=(bt_flag=flag) where=(flag=" "))
           num(in=bt drop=num where=(bt_flag="*"))
     ;
     by table dc_name var;

     if dc_name in ("ENC_L3_ENCTYPE_DDATE_YM" "ENC_L3_ENCTYPE_DISDISP" "ENC_L3_ENCTYPE_DISSTAT" 
        "ENC_L3_ENCTYPE_DRG" "ENC_L3_ENCTYPE_ADMRSC" "DIA_L3_PDX_ENCTYPE") then mvar=dc_name;
     else mvar=" ";
run;

proc sort data=num;
     by table mvar;
run;

*- Bring everything together -*;
data final(keep=pg ord col: perc thresholdflag);
     length col1-col5 col7-col9 $50;
     merge num denom(keep=table mvar denom bt_flag rename=(bt_flag=bt_denom));
     by table mvar;

     ord=put(var,$field.);
     col1=table;
     col2=var;
     if ord in ("06" "09" "10" "11" "12" "15") then col3="IP, IS, EI";
     else col3=" ";
     if num=. and bt_flag="*" then col4=strip(put(.t,threshold.));
     else col4=strip(put(num,comma16.))||strip(bt_flag);
     if denom=. and bt_denom="*" then col5=strip(put(.t,threshold.));
     else col5=strip(put(denom,comma16.))||strip(bt_denom);
     if num>0 and denom>0 then perc=num/denom*100;
     if ord in ("01" "02" "13" "17" "19") then do;
        col7="3.03";
        col8=">=5%";
        if perc>=5.00 then thresholdflag=1;
     end;
     else if ord in ("04" "09" "15") then do;
        col7="3.04";
        col8=">=15%";
        if perc>=15.00 then thresholdflag=1;
     end;
     else do;
        col7="--";
        col8="--";
     end;
     
     col9=dc_name;

     pg=1;
run;

proc sort;
     by ord;
run;

*- Produce output -*;
title1 justify=left "&_ttl1";
title2 justify=left h=2.5 "&_ttl2";
footnote1 justify=left "&_fnote";

proc report data=final split='~' style(header)=[backgroundcolor=CXCCCCCC];
     column thresholdflag perc pg col1 col2 col3 
            ("Records with missing, NI, UN, or OT values~_____________________________________" col4 col5 col6)
            ("Data Check~_________________" col7 col8) (" ~  " col9);

     define thresholdflag /display noprint;
     define perc     /display noprint;
     define pg       /order noprint;
     define col1     /display flow "Table" style(header)=[just=left cellwidth=12%] style(column)=[just=left];
     define col2     /display flow "Field" style(header)=[just=left cellwidth=17%] style(column)=[just=left];
     define col3     /display flow "Encounter Type~Constraint" style(header)=[just=center cellwidth=10%] style(column)=[just=center];
     define col4     /display flow "Numerator" style(header)=[just=center cellwidth=11%] style(column)=[just=center];
     define col5     /display flow "Denominator" style(header)=[just=center cellwidth=11%] style(column)=[just=center];
     define col6     /computed format=5.1 "%" style(header)=[just=center cellwidth=5%] style(column)=[just=center];
     define col7     /display flow "Data Check" style(header)=[just=center cellwidth=5%] style(column)=[just=center];
     define col8     /display flow "Threshold" style(header)=[just=center cellwidth=7%] style(column)=[just=center];
     define col9     /display flow "Source" style(header)=[just=left cellwidth=20%] style(column)=[just=left];

     compute col6;
        if thresholdflag=1 then do;
            col6=perc;
            call define(_col_, "style", "style=[color=red]");
        end;
        else do;
            col6=perc;
        end;
    endcomp;
run; 

ods listing;

*- Clear working directory -*;
%clean;

*******************************************************************************;
* Re-direct to default log
*******************************************************************************;
proc printto log=log;
run;
********************************************************************************;

*******************************************************************************;
* Close RTF
*******************************************************************************;
ods rtf close;
