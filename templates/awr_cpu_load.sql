with 
awr_pre as (
         select
             h.SAMPLE_TIME
            ,h.sample_id
            ,h.session_id            as sid
            ,h.session_serial#       as serial
            ,h.blocking_session
            ,h.user_id
            ,h.sql_id
            ,h.sql_exec_id
            ,h.top_level_sql_id
            ,h.plsql_entry_object_id ple
            ,h.plsql_object_id       plo
            ,decode(h.session_state,'ON CPU','ON CPU',h.event) as event
            ,h.p1,h.p1text
            ,h.p2,h.p2text
            ,h.p3,h.p3text
            ,h.wait_class
            ,h.current_obj#
            ,h.module
            ,substr(h.program,1,15) program
            ,h.action
            ,h.machine
         from dba_hist_snapshot sn
             ,dba_hist_active_sess_history h
         where sn.dbid=h.dbid
           and sn.snap_id=h.snap_id
           and sn.instance_number=h.instance_number
           and sn.begin_interval_time<=h.sample_time
           and sn.end_interval_time  >=h.sample_time
)
,ash_pre as (
         select
             h.SAMPLE_TIME
            ,h.sample_id
            ,h.session_id            as sid
            ,h.session_serial#       as serial
            ,h.blocking_session
            ,h.user_id
            ,h.sql_id
            ,h.sql_exec_id
            ,h.top_level_sql_id
            ,h.plsql_entry_object_id ple
            ,h.plsql_object_id       plo
            ,decode(h.session_state,'ON CPU','ON CPU',h.event) as event
            ,h.p1,h.p1text
            ,h.p2,h.p2text
            ,h.p3,h.p3text
            ,h.wait_class
            ,h.current_obj#
            ,h.module
            ,substr(h.program,1,15) program
            ,h.action
            ,h.machine
         from v$active_session_history h
         where 1=1
)
,ash as ( select * 
          from 
          (
             select h.sample_time
                   ,h.sid
                   ,h.serial
                   ,h.user_id
                   ,(select username from dba_users u where u.user_id=h.user_id) username
                   ,h.sql_id
                   ,h.sql_exec_id
                   ,h.top_level_sql_id
                   ,h.module
                   ,h.program
                   ,h.action
                   ,h.event
                   ,h.wait_class
                   ,h.current_obj#
                   ,(select object_name from dba_objects o where o.object_id=h.current_obj#) curobj
                   ,(select object_name from dba_objects o where o.object_id=h.ple) ple
                   ,(select object_name from dba_objects o where o.object_id=h.plo) plo
             from awr_pre h
             where 1=1
           -- and h.SAMPLE_TIME >= timestamp'2018-12-21 10:20:00'
           -- and h.sample_time <= timestamp'2017-07-12 11:30:00'
                               -- systimestamp - interval '1' hour
           -- and lower(h.module) like '%'
           -- and h.machine like '%'
           -- and h.program like '%'
           --   and (h.sql_id='&sqlid'  or h.top_level_sql_id='&sqlid')
           --order by sample_id desc
          )
          --where rownum<=20
)
,vload as(
  select 
    sample_time
   ,count(*) total_load
   ,count(decode(event,'ON CPU',1)) cpu_load
  from ash a
  group by sample_time
)
,v1 as (
  select
     trunc(sample_time) as dt
    ,max(total_load)    as max_total_load
    ,max(cpu_load)      as max_cpu_load
  from vload
  group by trunc(sample_time)
)
select to_char(dt,'yyyy-mm-dd') dt
       ,max_total_load
       ,max_cpu_load 
from v1
order by dt
/
