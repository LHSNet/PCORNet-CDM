/*--------------------------------------------------------------------------------------\

CDM 4.1 PROVIDER TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.PROVIDER (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT 
    PROVIDERID ,
    PROVIDER_SEX ,
    PROVIDER_SPECIALTY_PRIMARY ,
    PROVIDER_NPI ,
    PROVIDER_NPI_FLAG ,
    RAW_PROVIDER_SPECIALTY_PRIMARY
FROM cdm_in.PROVIDER
;
