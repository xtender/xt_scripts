@inc/input_vars_init;
pro ********************************************************
pro * Shows last 20 APEX SQLs from RTSM and all Executing.
pro * optional parameter - page number...
pro ********************************************************
col sql_id   format a13 ;
col sql_text format a120;
col stext30  format a30 ;
col username    for a20;
col program     for a20 noprint;
col module      for a23;
col apex_schema for a12;
col apex_app    for a8;
col apex_page   for a5 heading page;
col apex_client for a25;

col plan_object_name for a40;

col wait_class for a20 trunc;
col event      for a50 trunc;

with apex as (
select
  r.*
  ,regexp_substr(module,'([^/]+)/APEX:APP (\d+):(\d+)',1,1,null,1) apex_schema
  ,regexp_substr(module,'([^/]+)/APEX:APP (\d+):(\d+)',1,1,null,2) apex_app
  ,regexp_substr(module,'([^/]+)/APEX:APP (\d+):(\d+)',1,1,null,3) apex_page
  ,regexp_substr(r.client_identifier,'([^:]*):(.*)',1,1,null,1)    apex_client
  ,row_number()over(order by LAST_REFRESH_TIME desc) rnk_last
--  ,(select username from dba_users u where u.user_id=h.user_id) username
from --gv$active_session_history h
     gv$sql_monitor r
where 1=1
  --and user_id = (select user_id from dba_users where username='ORDS_PLSQL_GATEWAY')
  and username = 'ORDS_PLSQL_GATEWAY'
  and program = 'ORDS_ADBS_Managed'
  and module like '%/APEX:APP %'
  and regexp_substr(module,'([^/]+)/APEX:APP (\d+):(\d+)',1,1,null,3) like nvl(replace('&1','*','%'),'%')
  and px_server# is null
)
, rtsm_apex as (
    select
       r.sid
      ,apex_schema
      ,apex_app
      ,apex_page
      ,apex_client
      ,r.sql_id
      ,r.status
      ,substr(regexp_replace(translate(trim(r.sql_text),'x'||chr(10),'x '),'\s{2,}',' '),1,30) stext30
      ,r.sql_exec_id
      ,r.sql_plan_hash_value        as plan_hv
 --   ,r.user#
 --   ,r.username
 --   ,r.module
 --   ,r.program
      ,r.sql_exec_start
      ,r.ELAPSED_TIME/1e6           as ela_exe
      ,r.CPU_TIME/1e6               as cpu_exe
      ,r.APPLICATION_WAIT_TIME/1e6  as app_exe
      ,r.CONCURRENCY_WAIT_TIME/1e6  as cc_exe
      ,r.USER_IO_WAIT_TIME/1e6      as io_exe
      ,r.PLSQL_EXEC_TIME/1e6        as plsql_exe
      ,r.fetches
      ,r.buffer_gets
      ,r.DISK_READS
 --     ,r.sql_text
 --     ,r.is_full_sqltext
     ,o.*
  from apex r
         outer apply(
           select 
              p.plan_object_name
             ,v.*
           from 
             (select h.sql_plan_line_id,h.sql_plan_operation,count(*) cnt
               from v$active_session_history h
               where h.sql_id=r.sql_id
               and h.sql_exec_id=r.sql_exec_id
              -- and h.sql_plan_operation like '%ACCESS%'
               and r.sql_plan_hash_value>0
               and h.sample_time>systimestamp-interval'5' minute
              group by h.sql_plan_line_id,h.sql_plan_operation
              order by cnt desc
              fetch first 1 row only
             ) v
            left join v$sql_plan_monitor p
              on p.sql_id=r.sql_id
              and p.sql_exec_id=r.sql_exec_id
              and p.plan_line_id = v.sql_plan_line_id
              and p.sid=r.sid
         ) o
  where rnk_last<=to_number(nvl('&2','20') default 20 on conversion error) or status='EXECUTING'
  --order by LAST_REFRESH_TIME desc
  --fetch first 20 rows only
)
select/*+ no_parallel */
     a.*
    ,decode(s.state,'WAITING', s.wait_class ,'ON CPU')                       as wait_class
    ,decode(s.state,'WAITING', s.event      ,'ON CPU')                       as event
from rtsm_apex a
join v$session s on a.sid=s.sid;
@inc/input_vars_undef;