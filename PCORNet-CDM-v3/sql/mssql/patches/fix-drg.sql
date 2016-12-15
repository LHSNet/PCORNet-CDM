begin transaction
--select drg from PCORI_CDMv3.encounter where drg is not null and len(drg) > 3;
update PCORI_CDMv3.encounter set drg = substring(drg, 1, 3) where drg is not null and (len(drg) > 3);
commit


select drg from PCORI_CDMv3.encounter where drg is not null;