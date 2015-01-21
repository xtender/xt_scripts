def _mask='&1'

col sql_handle     for a30
col sql_text       for a120 trunc
col plan_name      for a30
col ORIGIN         for a15 trunc
col DESCRIPTION    for a50
col created        for a19
col last_modified  for a19
col last_executed  for a19
col last_verified  for a19
--col enabled
--col accepted
--col fixed
--col reproduced
--col autopurge
--col optimizer_cost
col module         for a10 trunc
col action         for a10 trunc
col elaexe         for a12
col cpu_time       for a12
--col buffer_gets
--col disk_reads
--col direct_writes
--col rows_processed
--col fetches
--col end_of_fetch_count


select 
   b.sql_handle
  ,b.sql_text
  ,b.plan_name
  ,b.ORIGIN
  ,b.DESCRIPTION
  ,to_char(b.created       ,'yyyy-mm-dd hh24:mi:ss')                 as created      
  ,to_char(b.last_modified ,'yyyy-mm-dd hh24:mi:ss')                 as last_modified
  ,to_char(b.last_executed ,'yyyy-mm-dd hh24:mi:ss')                 as last_executed
  ,to_char(b.last_verified ,'yyyy-mm-dd hh24:mi:ss')                 as last_verified
  ,b.enabled
  ,b.accepted
  ,b.fixed
  ,b.reproduced
  ,b.autopurge
  ,b.optimizer_cost
  ,b.module
  ,b.action
  ,b.executions
  ,to_char(b.elapsed_time/1e6/nullif(b.executions,0),'fm999990.00000') as elaexe
  ,to_char(b.cpu_time    /1e6/nullif(b.executions,0),'fm999990.00000') as cpu_time
  ,round(b.buffer_gets       /nullif(b.executions,0),2)              as buffer_gets
  ,round(b.disk_reads        /nullif(b.executions,0),2)              as disk_reads
  ,round(b.direct_writes     /nullif(b.executions,0),2)              as direct_writes
  ,round(b.rows_processed    /nullif(b.executions,0),2)              as rows_processed
  ,round(b.fetches           /nullif(b.executions,0),2)              as fetches_exe
  ,b.end_of_fetch_count
from dba_sql_plan_baselines b
where b.sql_text   like q'[&_mask]'
   or b.sql_handle like q'[&_mask]'
   or b.plan_name  like q'[&_mask]'
   or b.signature in (select exact_matching_signature from v$sqlarea a where length(q'[&_mask]')=13 and a.sql_id = q'[&_mask]')
;
