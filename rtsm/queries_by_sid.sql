select 
   r.sql_id
  ,sql_exec_start
  ,sql_exec_id 
  ,status
  ,elapsed_time
  ,cpu_time
from v$sql_monitor r 
where r.sid=&1;