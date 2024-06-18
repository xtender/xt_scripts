@inc/input_vars_init;

col username    for a20;
col program     for a20 noprint;
col module      for a23;
col apex_schema for a12;
col apex_app    for a8;
col apex_page   for a5 heading page;
col apex_client for a12;
col sample_first for a23;
col sample_last for a23;

with apex as (
select 
  h.*
  ,regexp_substr(module,'([^/]+)/APEX:APP (\d+):(\d+)',1,1,null,1) apex_schema
  ,regexp_substr(module,'([^/]+)/APEX:APP (\d+):(\d+)',1,1,null,2) apex_app
  ,regexp_substr(module,'([^/]+)/APEX:APP (\d+):(\d+)',1,1,null,3) apex_page
  ,regexp_substr(client_id,'([^:]*):(.*)',1,1,null,1) apex_client
  ,(select username from dba_users u where u.user_id=h.user_id) username
from gv$active_session_history h
where 1=1
  and user_id = (select user_id from dba_users where username='ORDS_PLSQL_GATEWAY')
  and program = 'ORDS_ADBS_Managed'
  and module like '%/APEX:APP %'
)
select/*+ no_parallel */
   username,
   module
  ,program
  ,apex_schema
  ,apex_app
  ,apex_page
  ,apex_client
--  ,client_id
  ,sql_id
  ,min(sample_time) sample_first
  ,max(sample_time) sample_last
  ,count(*) cnt
from apex a
where a.sample_time>sysdate - numtodsinterval(nvl('&1','5'), 'minute')
group by username,
   module
  ,program
  ,apex_schema
  ,apex_app
  ,apex_page
  ,apex_client
--  ,client_id
  ,sql_id
order by 1,2,3;
@inc/input_vars_undef;