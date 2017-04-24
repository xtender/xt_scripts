@inc/input_vars_init;
col name for a80;
select 
    id,type,status
    ,substr(name,1,max(length(name))over()) name
    ,namespace,creation_timestamp,scn
    ,pin_count,scan_count,invalidations
from v$result_cache_objects o 
where lower(o.name) like lower('%&1%')
and (scan_count>0 or invalidations>0)
/
col name clear;
@inc/input_vars_undef;