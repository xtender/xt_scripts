col sql_id      for a13;
col status      for a25 trunc;
col sql_text    for a120 trunc;
select 
   sql_id
  ,sql_exec_start
  ,sql_exec_id 
  ,status
  ,round(elapsed_time/1e6,3) elapsed_time
  ,round(cpu_time/1e6,3)    cpu_time
  ,sql_text
from (
      select 
         sql_id
        ,sql_exec_start
        ,sql_exec_id 
        ,status
        ,elapsed_time
        ,cpu_time
        ,sql_text
        ,dense_rank()over(order by sql_exec_start) rnk
      from v$sql_monitor r 
      where r.sid=&1
) v
where rnk<=20 or status='EXECUTING'
;
col sql_id      clear;
col status      clear;
col sql_text    clear;
