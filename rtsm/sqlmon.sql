col status                                   format a10
col plan_line_id     heading ID;
col operation        heading Operation       format a50;
col PLAN_OBJECT_TYPE heading "Object type"   format a20;
col PLAN_OBJECT_NAME heading Object          format a20;
col plan_depth       noprint;
col plan_position    noprint;
col plan_cost        heading Cost
col plan_cardinality heading cardinality
----
col plan_partition_start heading PSTART      format a10;
col plan_partition_stop  heading PSTOP       format a10;
set head off
col "Current time"                           format a80
select 'Current time: '||to_char(systimestamp,'yyyy-mm-dd hh24:mi:ss') "Current time" from dual;
set head on
break on sid skip 1
select 
     sid
   , status
 --  plan_parent_id
   , plan_line_id
   ,    lpad(' ',2*(plan_depth),' ')
     || plan_operation ||decode(plan_options,null,null,' ( '|| plan_options || ' ) ') as operation
--   , plan_operation      , plan_options
   , plan_object_type    , plan_object_name  
--   , plan_depth          , plan_position
   , plan_cost           , plan_cardinality
   , plan_cpu_cost       , plan_io_cost
   , plan_bytes          , plan_time
   , starts              , output_rows
   , plan_partition_start, plan_partition_stop
   , plan_temp_space
   , physical_read_bytes , physical_read_requests
   , physical_write_bytes, physical_write_requests
   , workarea_mem        , workarea_max_mem
   , workarea_tempseg    , workarea_max_tempseg
   , io_interconnect_bytes
-- , key                 , status
-- , first_refresh_time  , last_refresh_time
-- , first_change_time   , last_change_time
-- , refresh_count       , sid,process_name
-- , sql_id              , sql_exec_start
from v$sql_plan_monitor mp 
where 1 = 1
  and mp.sql_id='&1'
--  and 
order by sid,sql_id,sql_plan_hash_value,sql_exec_id,plan_line_id
/
col status           clear;
col plan_cardinality heading cardinality
----
col plan_partition_start heading PSTART      format a10;
col plan_partition_stop  heading PSTOP       format a10;

col plan_depth           clear;
col plan_position        clear;
col plan_cost            clear;

col plan_object_type     clear;
col plan_object_name     clear;
col plan_line_id         clear;
col operation            clear;
col plan_partition_start clear
col plan_partition_stop  clear
clear break
@inc/params_undef
