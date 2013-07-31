with ash_mon as (
      select--+ index(@SEL$31 ash@sel$31 WRH$_ACTIVE_SESSION_HISTORY_PK) 
          h.*
         ,(select username from dba_users u where u.user_id=h.user_id) username
         ,coalesce(
            (select a.sql_text from v$sqlarea a where a.sql_id=h.sql_id and rownum=1)
            ,(select substr(to_char(a.sql_text),1,4000) from dba_hist_sqltext a where a.sql_id=h.sql_id and rownum=1 and dbid=(select dbid from v$database))
          ) text
         ,(select object_name from dba_objects o where o.object_id=h.plsql_entry_object_id) ple
         ,(select object_name from dba_objects o where o.object_id=h.plsql_object_id) plo
         ,(select object_name from dba_objects o where o.object_id=h.current_obj#) curobj
      from gv$active_session_history h
           --sys.WRH$_ACTIVE_SESSION_HISTORY h
           --dba_hist_active_sess_history h
      where h.SAMPLE_TIME >sysdate-&minutes/24/60
             /*
           between timestamp'2013-03-04 13:50:00'
               and timestamp'2013-03-04 14:05:00'
                              --*/
      --and (h.sql_id='&sql_id')
      --and session_id=&sid   
      and user_id in (select user_id from dba_users where username='BICHEEVA')
      --and h.SESSION_SERIAL#=13537

      /*and (h.BLOCKING_SESSION in (1141,1191,1205,1200,1301,1336,1142,1376,1352,1230,3815,2705,1477)
          or session_id in (1141,1191,1205,1200,1301,1336,1142,1376,1352,1230,3815,2705,1477)
          )
      and h.BLOCKING_SESSION is not null*/
      --and h.session_id=&sid 
      --and event_id not in (2652584166,3999721902)
      --and h.dbid = (select dbid from v$database)
)
select
    user_id
   ,username
   ,session_id
   ,session_serial#
   ,top_level_call#
   ,top_level_call_name
   ,ple
   ,plo
   ,a.sql_id
   ,SESSION_STATE
   ,wait_class
   ,TIME_MODEL
   ,event
   ,sql_text
   ,count(*)                           as CNT
   ,count(*) over(partition by a.sql_id) as cnt_sqlid
   ,count(*) over(partition by ple)    as cnt_ple
   ,sum(wait_time)
   ,sum(time_waited)
   ,sum(TM_DELTA_TIME)
   ,sum(TM_DELTA_CPU_TIME)
   ,sum(TM_DELTA_DB_TIME)
   ,sum(DELTA_TIME)
   ,min(temp_space_allocated)
   ,max(temp_space_allocated)
   ,avg(temp_space_allocated)
   ,min(PGA_ALLOCATED)
   ,max(PGA_ALLOCATED)
   ,avg(PGA_ALLOCATED)

from ash_mon
     left join (select sql_id,sql_text from v$sqlarea a) a
     on a.sql_id=ash_mon.sql_id
group by 
    user_id
   ,username
   ,session_id
   ,session_serial#
   ,top_level_call#
   ,top_level_call_name
   ,ple
   ,plo
   ,a.sql_id
   ,SESSION_STATE
   ,wait_class
   ,TIME_MODEL
   ,event
   ,sql_text
order by 
      cnt_ple      desc
     ,cnt_sqlid    desc
     ,cnt          desc
/
