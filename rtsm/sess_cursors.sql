@inc/input_vars_init.sql;
col ple         format a20;
col plo         format a20;
col sql_text    format a100;
col username    format a15;
col status      format a18;
select 
  m.STATUS
 ,m.username
 ,m.SQL_EXEC_ID
 ,m.SQL_EXEC_START
 ,m.SQL_PLAN_HASH_VALUE
 ,m.SID,m.SESSION_SERIAL#
 ,m.sql_text
-- ,m.module
-- ,m.action
 ,(select p.owner||'.'||p.OBJECT_NAME||nvl2(p.PROCEDURE_NAME,'.'||p.PROCEDURE_NAME,'')
   from dba_procedures p 
   where p.OBJECT_ID     = m.PLSQL_ENTRY_OBJECT_ID 
     and p.SUBPROGRAM_ID = m.PLSQL_ENTRY_SUBPROGRAM_ID
  ) ple
 ,(select p.owner||'.'||p.OBJECT_NAME||nvl2(p.PROCEDURE_NAME,'.'||p.PROCEDURE_NAME,'')
   from dba_procedures p 
   where p.OBJECT_ID     = m.PLSQL_OBJECT_ID 
     and p.SUBPROGRAM_ID = m.PLSQL_SUBPROGRAM_ID
  ) plo

 ,to_char(m.ELAPSED_TIME/1e6,'9999999.99') ela_secs
 ,to_char(m.CPU_TIME/1e6,'9999999.99') CPU_secs
 ,m.fetches
 ,m.BUFFER_GETS
 ,m.DISK_READS
 ,m.DIRECT_WRITES
 ,m.PHYSICAL_READ_REQUESTS
 ,m.PHYSICAL_READ_BYTES
 ,m.PHYSICAL_WRITE_REQUESTS
 ,m.PHYSICAL_WRITE_BYTES
 ,m.APPLICATION_WAIT_TIME
 ,m.CONCURRENCY_WAIT_TIME
 ,m.USER_IO_WAIT_TIME
 ,m.PLSQL_EXEC_TIME
from v$sql_monitor m
where m.sid=700
  and m.sql_exec_start>= sysdate - nvl2('&2',&2+0,120)/24/60
  and m.status like nvl('&3','%')
/
col ple         clear;
col plo         clear;
col sql_text    clear;
col username    clear;
col status      clear;
@inc/input_vars_undef.sql;