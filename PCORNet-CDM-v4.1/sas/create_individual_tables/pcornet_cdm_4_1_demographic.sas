/*--------------------------------------------------------------------------------------\

CDM 4.1 DEMOGRAPHIC TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.DEMOGRAPHIC (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT
    PATID , 
    INPUT( PUT(BIRTH_DATE , e8601da.) , e8601da.) AS BIRTH_DATE format date9., 
	INPUT( BIRTH_TIME , time.) AS BIRTH_TIME format hhmm.,
    SEX ,
	SEXUAL_ORIENTATION ,
	GENDER_IDENTITY ,
    HISPANIC ,
    RACE ,
    BIOBANK_FLAG ,
    PAT_PREF_LANGUAGE_SPOKEN ,
	RAW_SEX ,
	RAW_SEXUAL_ORIENTATION,
	RAW_GENDER_IDENTITY,
    RAW_HISPANIC ,
    RAW_RACE ,
	RAW_PAT_PREF_LANGUAGE_SPOKEN
FROM cdm_in.DEMOGRAPHIC
;

