col username       new_val p_username       noprint;
col sql_id         new_val p_sql_id         noprint;
col sql_exec_start new_val p_sql_exec_start noprint;
col sql_exec_id    new_val p_sql_exec_id    noprint;

col SQL_PLAN_OPERATION for a20 trunc;
col SQL_PLAN_OPTIONS   for a20 trunc;
col OPNAME             for a20 trunc;
col TARGET             for a20 trunc;
col MESSAGE            for a64 trunc;

break on username on sql_id on sql_exec_start on sql_exec_id skip page;
ttitle left -
     'USERNAME: ' p_username       skip 1-
     'SQL_ID  : ' p_sql_id         skip 1-
     'START   : ' p_sql_exec_start skip 1-
     'EXEC_ID : ' p_sql_exec_id    skip 2;

select 
  username
 ,l.sql_id
 ,l.sql_exec_start
 ,l.sql_exec_id
 ,sid,serial#
 ,l.sql_plan_line_id        as "LINE#"
 ,l.sql_plan_operation
 ,l.sql_plan_options
 ,opname,target
 ,sofar, totalwork
 ,l.time_remaining          as remaining
 ,l.elapsed_seconds         as elapsed
 ,l.message
 ,last_update_time
from v$session_longops l
where --l.sql_id='410hc47j3dqxr'
(l.sid,l.serial#)
      in 
        (select ss.sid,ss.serial#
         from v$session ss
         where ss.osuser   = sys_context('USERENV','OS_USER')
           and ss.terminal = userenv('terminal') 
         )
order by 
  l.sql_id
 ,l.SQL_EXEC_ID
 ,l.SQL_PLAN_LINE_ID
 ,opname,sid
/
clear break;
clear col;
ttitle off;
