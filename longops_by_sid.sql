select 
  l.sid
 ,l.serial#
 ,l.qcsid
 ,l.start_time
 ,l.last_update_time
 ,l.opname
 ,l.target
 ,l.target_desc
 ,l.sofar||'/'||l.totalwork as progress
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
where l.sid = &1
/