col username for a30;
col module   for a20 trunc;
col stext    for a100 trunc;
col my_sqlid for a13 new_value my_sqlid;

select 
  r.username
 ,r.MODULE
 ,r.sid
 ,r.session_serial# as serial#
 ,r.sql_id          as my_sqlid
 ,r.sql_exec_id
 ,r.sql_exec_start
 ,replace(r.SQL_TEXT,chr(10))        as stext
 ,r.elapsed_time
 ,r.cpu_time
 ,r.user_io_wait_time
-- ,r.sql_plan_hash_value

from v$session ss
    ,v$sql_monitor r
where 
      ss.osuser = sys_context('USERENV','OS_USER')
  and ss.status = 'ACTIVE'
  and ss.SID   != USERENV('SID')
  and r.sid=ss.sid
  and r.status    = 'EXECUTING'
order by r.sql_exec_start desc;

col username clear;
col module   clear;
col stext    clear;
col my_sqlid clear;


@rtsm/sqlid &my_sqlid