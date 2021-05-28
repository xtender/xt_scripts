@inc/input_vars_init;
prompt ;
prompt *** Get and save an incident file
prompt * Usage: @diag/incident_files_spool_by_id incident_id
prompt *
prompt *** NB: you should have created ADR_HOME directory to access incident files...
prompt * checking it...

col directory_name for a8;
col directory_path for a80;
select directory_name,directory_path from all_directories where directory_name='ADR_HOME';


col BFILE     new_value _bfile for a80 noprint;
col real_path new_value _path for a80 noprint;
col file_name new_value _name  for a30;
select
 INCIDENT_ID
,OWNER_ID
,FLAGS
--,CON_UID
,CON_ID
,BFILE
,regexp_replace(replace(f.bfile,'<ADR_HOME>/'),'#0$','') real_path
,regexp_substr(f.bfile, '([^/\]+)#0$',1,1,null,1) as file_name
from v$diag_incident_file f 
where incident_id = &1
and flags=1 -- incident
order by incident_id;

col BFILE clear;
col real_path clear;
col file_name clear;

prompt Original BFILE: &_bfile
prompt Real path: &_path
prompt File name: &_name

accept _cont prompt "Continue? [Y/N]: ";

set feed off head off timing off pages 0 long 100000000 termout off;
spool &_name replace;
select to_clob(bfilename('ADR_HOME', '&_path')) inc_file_contents 
from v$diag_incident_file i
where upper('&_cont')='Y'
  and incident_id = &1
  and flags=1 -- incident
;
spool off;
@inc/input_vars_undef;
