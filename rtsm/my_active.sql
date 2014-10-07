col username for a30;
col command  for a15 trunc;
col module   for a10 trunc;
col stext    for a100 trunc;
col my_sqlid for a13 new_value my_sqlid;

select 
                       r.username
&_IF_ORA112_OR_HIGHER ,(select c.COMMAND_NAME from v$sqlcommand c where c.COMMAND_TYPE = a.COMMAND_TYPE) as command
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
    ,v$sqlarea a
where 
      ss.osuser = sys_context('USERENV','OS_USER')
  and ss.status = 'ACTIVE'
  and ss.SID   != USERENV('SID')
  and r.sid     = ss.sid
  and r.status  = 'EXECUTING'
  and a.sql_id  = r.sql_id
order by decode(a.command_type,47,0,1) --pl/sql last
        ,r.sql_exec_start desc;

col username clear;
col command  clear;
col module   clear;
col stext    clear;
col my_sqlid clear;


@rtsm/sqlid &my_sqlid
