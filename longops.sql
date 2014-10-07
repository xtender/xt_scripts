accept _minutes prompt "How many minutes[default 1]: " default 1;

col username            for a30;
col message             for a80;
col opname              for a30;
col target              for a30;
col target_desc         for a30;
col progress            for a30;
col units               for a15;
col sql_plan_operation  for a40;
col sql_plan_options    for a15;

select 
  l.sid
 ,l.serial#
 ,l.qcsid
 ,l.start_time
 ,l.last_update_time
 ,l.opname
 ,l.target
 ,l.target_desc
 ,to_char(l.sofar*100/nullif(l.totalwork,0),'990')||'% ('||l.sofar||'/'||l.totalwork||')' as progress
 ,l.units
 ,l.elapsed_seconds
 ,l.time_remaining
 ,l.message
 ,l.username
 ,l.sql_id
 ,l.sql_plan_line_id
 ,l.sql_plan_operation
 ,l.sql_plan_options
from v$session_longops l
where last_update_time>sysdate - 0&_minutes/24/60;

undef _minutes;
col username            clear;
col message             clear;
col opname              clear;
col target              clear;
col target_desc         clear;
col progress            clear;
col units               clear;
col sql_plan_operation  clear;
col sql_plan_options    clear;