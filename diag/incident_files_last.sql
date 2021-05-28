@inc/input_vars_init;

col BFILE for a120;
select
 INCIDENT_ID
,OWNER_ID
,FLAGS
--,CON_UID
,CON_ID
,BFILE
from v$diag_incident_file f 
order by incident_id desc fetch first nvl('&1',10) rows only;

col BFILE clear;
@inc/input_vars_undef;
