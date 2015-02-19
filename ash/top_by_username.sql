prompt *** Top SQL`s by username for last N minutes:
prompt * Usage: ash/top_by_username username_mask minutes

@inc/input_vars_init

col username         for a30;
col MACHINE          for a25;
col top_level_sql_id for a13;
col top_text         for a100;
col text             for a100;
select 
    h.session_id
   ,h.session_serial#
   ,h.MACHINE
   ,(select u.username from dba_users u where u.user_id=h.user_id) username
   ,h.top_level_sql_id
   ,h.sql_id
   ,h.SQL_PLAN_HASH_VALUE as plan_hv
   ,h.SQL_CHILD_NUMBER    as ch#
   ,(select s.elapsed_time/nullif(s.executions,0)/1e6  
     from v$sql s 
     where s.sql_id          = h.sql_id 
       and s.plan_hash_value = h.sql_plan_hash_value 
       and s.child_number    = h.sql_child_number
    ) as elaexe
   ,sum(count(*)) over(partition by h.TOP_LEVEL_SQL_ID) top_cnt
   ,count(*) cnt
   ,(select substr(sql_text,1,100) from v$sqlarea a where a.sql_id=h.TOP_LEVEL_SQL_ID)  as top_text
   ,(select substr(sql_text,1,100) from v$sqlarea a where a.sql_id=h.sql_id)            as text
   ,sum(count(*)) over(partition by h.session_id,h.session_serial#)                     as ses_cnt
from v$active_session_history h
where h.sample_time > systimestamp - interval '0&2' minute
  and (
        exists (select h.user_id from dba_users u where u.username like upper('%&1%') and h.user_id = u.user_id)
        or
        upper(h.MACHINE) like upper('%&1%')
      )
group by
    h.session_id
   ,h.session_serial#
   ,h.MACHINE
   ,h.user_id
   ,h.TOP_LEVEL_SQL_ID
   ,h.sql_id
   ,h.SQL_PLAN_HASH_VALUE
   ,h.SQL_CHILD_NUMBER
order by 
    ses_cnt desc
   ,h.session_id
   ,h.session_serial#
   ,h.MACHINE
   ,h.user_id
   ,top_cnt desc, cnt desc
/
col username         clear;
col MACHINE          clear;
col top_level_sql_id clear;
col top_text         clear;
col text             clear;
@inc/input_vars_undef
