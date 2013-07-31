@inc/input_vars_init;
prompt "&1"
select * 
from dba_tab_modifications tm
where tm.table_owner like nvl(upper('&2'),'%')
  and tm.table_name = upper('&1');

select object_type,created,last_ddl_time,timestamp 
from  dba_objects o
where o.owner like nvl(upper('&2'),'%')
  and o.object_name=upper('&1');

@inc/input_vars_undef;
