accept sql_id     prompt "SQL_ID: ";
accept time_start prompt "Time start[yyyy-mm-dd hh24:mi:ss]: ";
accept time_end   prompt "Time end  [yyyy-mm-dd hh24:mi:ss]: ";

--col  sql_exec_id     for 9999999
col  sql_id         for a13
--col  plan_hv        for a
col  operation      for a60
col  OBJECT_TYPE    for a15 trunc
col  OBJECT_OWNER   for a15
col  OBJECT_NAME    for a30
col  OBJECT_ALIAS   for a20
col  QBLOCK_NAME    for a15
col  wait_class     for a20
col  event          for a64

break on sql_exec_id  -
      on sql_id       -
      on plan_hv      -
      on operation    -
      on OBJECT_TYPE  -
      on OBJECT_OWNER -
      on OBJECT_NAME  -
      on OBJECT_ALIAS -
      on QBLOCK_NAME;

with 
  snaps as ( select sn.snap_id, sn.dbid, sn.instance_number
             from dba_hist_snapshot sn
             where sn.end_interval_time   >= timestamp'&time_start'
               and sn.begin_interval_time <= timestamp'&time_end'
  )
, ash as (
      select-- materialize
          h.SQL_ID
         ,h.SQL_EXEC_ID
         ,h.SQL_EXEC_START
         ,h.SQL_PLAN_HASH_VALUE as plan_hv
         ,h.SQL_PLAN_LINE_ID
         ,decode(session_state,'ON CPU',session_state,wait_class) wait_class
         ,h.event
         ,count(*) cnt
      from dba_hist_active_sess_history h
          ,snaps sn
      where
           sn.snap_id = h.snap_id
       and sn.dbid    = h.dbid
       and sn.instance_number = h.instance_number
       and h.sql_id = '&sql_id' 
      group by
          h.SQL_ID
         ,h.SQL_EXEC_ID
         ,h.SQL_EXEC_START
         ,h.SQL_PLAN_HASH_VALUE
         ,h.SQL_PLAN_LINE_ID
         ,decode(session_state,'ON CPU',session_state,wait_class)
         ,h.event
  )
, execs as (
     select distinct SQL_ID,SQL_EXEC_ID
     from ash
)
, plans as (
      select--+ materialize
         p.sql_id
        ,p.plan_hash_value                 as plan_hv
        ,p.id
        ,rpad('  ',2+depth*2,'  ')
           ||p.operation||' '||p.OPTIONS
         as operation
        ,OBJECT_TYPE
        ,OBJECT_OWNER
        ,OBJECT_NAME
        ,OBJECT_ALIAS
        ,QBLOCK_NAME
      from dba_hist_sql_plan p
      where p.dbid in (select db.dbid from v$database db)
        and p.sql_id = '&sql_id'
        and exists( select null 
                    from ash 
                    where ash.sql_id = p.sql_id 
                    and ash.plan_hv  = p.plan_hash_value
                  )
)
select 
   e.sql_exec_id
  ,pl.sql_id
  ,pl.plan_hv
  ,pl.operation
  ,pl.OBJECT_TYPE
  ,pl.OBJECT_OWNER
  ,pl.OBJECT_NAME
  ,pl.OBJECT_ALIAS
  ,pl.QBLOCK_NAME
  ,a.wait_class
  ,a.event
  ,a.cnt
from execs e
     join plans pl
          on e.sql_id = pl.sql_id --  for each execution_id:
     left join ash a
          on  pl.sql_id      = a.sql_id
          and pl.plan_hv     = a.plan_hv
          and pl.id          = a.SQL_PLAN_LINE_ID
          and e.sql_exec_id  = a.sql_exec_id
where 1=1
order by e.sql_exec_id,pl.sql_id,pl.plan_hv,pl.id
/
col  sql_id         clear;
col  operation      clear;
col  OBJECT_TYPE    clear;
col  OBJECT_OWNER   clear;
col  OBJECT_NAME    clear;
col  OBJECT_ALIAS   clear;
col  QBLOCK_NAME    clear;
col  wait_class     clear;
col  event          clear;
clear break;
