/*

-- max len of drg
select max(len(drg)) from pcornetcdmv3.encounter
5

*/

ALTER TABLE pcori_cdmv3.encounter 
    ALTER COLUMN drg VARCHAR(12);
