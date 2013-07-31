col owner   format a15;
col name    format a30;
col db_link format a15;
col type    format a15;
@inc/input_vars_init;
select 
  oc.owner
 ,oc.name
 ,oc.db_link
 ,oc.type
 ,oc.loads
 ,oc.executions
 ,oc.locks
 ,oc.pins
 ,oc.invalidations
 ,oc.locked_total
 ,oc.pinned_total
 ,oc.pin_mode
 ,oc.status
 ,oc.timestamp
from v$db_object_cache oc 
where 
     oc.owner like nvl(upper('&2'),'%')
 and oc.name  like nvl(upper('&1'),'%')
/
@inc/input_vars_undef;
col owner   clear;
col name    clear;
col db_link clear;
col type    clear;