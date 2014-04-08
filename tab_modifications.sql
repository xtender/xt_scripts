@inc/input_vars_init;
prompt &_C_RED * Show stats from dba_tab_modifications: &_C_RESET;
prompt * Usage: @tab_modifications table_mask [owner_mask];

select 
    to_char(systimestamp,'yyyy-mm-dd hh24:mi:ss') run_dt
   ,m.table_owner
   ,m.table_name
   ,m.inserts
   ,m.updates
   ,m.deletes
   ,m.timestamp
   ,m.truncated
   ,m.drop_segments
from dba_tab_modifications m
where 
     m.table_owner like upper(nvl('&2','%'))
 and m.table_name like upper('&1')
/

select object_type,created,last_ddl_time,timestamp 
from  dba_objects o
where o.owner like nvl(upper('&2'),'%')
  and o.object_name=upper('&1');

prompt Later you can reexecute query after updating with: call dbms_stats.flush_database_monitoring_info();
@inc/input_vars_undef;
