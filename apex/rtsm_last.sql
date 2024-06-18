@inc/input_vars_init;
pro ********************************************************
pro * Shows N last APEX SQLs from RTSM and all Executing.
pro * optional parameters:
pro * - page number
pro * - number of SQLs
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
col apex_client for a12;


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
      ,substr(regexp_replace(trim(r.sql_text),'\s{2,}',' '),1,30) stext30
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
  from apex r
  where rnk_last<=to_number(nvl('&2','20') default 20 on conversion error) or status='EXECUTING'
  --order by LAST_REFRESH_TIME desc
  --fetch first 20 rows only
)
select *
from rtsm_apex a;
