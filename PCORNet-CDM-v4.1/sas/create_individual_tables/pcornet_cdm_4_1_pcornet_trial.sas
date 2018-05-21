/*--------------------------------------------------------------------------------------\

CDM 4.1 PCORNET_TRIAL TABLE

\--------------------------------------------------------------------------------------*/

proc sql noprint;

create table cdm_out.PCORNET_TRIAL (compress=yes encrypt=aes encryptkey=&aeskey) as

SELECT PATID ,
       TRIALID ,
       PARTICIPANTID ,
       TRIAL_SITEID ,
       INPUT( PUT(TRIAL_ENROLL_DATE , e8601da.) , e8601da.) AS TRIAL_ENROLL_DATE format date9.,
       INPUT( PUT(TRIAL_END_DATE , e8601da.) , e8601da.) AS TRIAL_END_DATE format date9.,
       INPUT( PUT(TRIAL_WITHDRAW_DATE , e8601da.) , e8601da.) AS TRIAL_WITHDRAW_DATE format date9.,
       TRIAL_INVITE_CODE
FROM cdm_in.PCORNET_TRIAL
;

