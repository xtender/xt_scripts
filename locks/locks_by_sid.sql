prompt &_C_RED *** Show locks by sid &_C_RESET;
prompt &_C_REVERSE Usage: @locks/locks_by_sid sid &_C_RESET;
prompt 

@inc/input_vars_init;

col object format a40;
col descr  format a130;
select
                        l.* 
                       ,(select owner||'.'||object_name from dba_objects o where o.object_id=l.id1) object
&_IF_ORA112_OR_HIGHER  ,(select t.description from v$lock_type t where t.type=l.type) descr
from v$lock l 
where l.sid=&1
order by l.type, l.ctime
/
col object clear;
col descr  clear;
@inc/input_vars_undef;
