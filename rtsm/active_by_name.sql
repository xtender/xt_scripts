col username for a30;
col program  for a20 trunc;
col sql_id   for a13;
col status   for a10;
col qtext    for a80 trunc;
col pl_obj   for a50;
col ple_obj  for a50;
select r.username
      ,r.program
      ,r.sid
      ,r.sql_id
      ,translate(substr(r.SQL_TEXT,1,80),chr(10),' ') qtext
      ,r.SQL_EXEC_START
      ,r.status
      ,r.ELAPSED_TIME
      ,r.fetches
      ,r.buffer_gets
      ,r.disk_reads
      ,r.direct_writes
      ,r.io_interconnect_bytes
      ,r.physical_read_requests
      ,r.physical_read_bytes
      ,r.physical_write_requests
      ,r.physical_write_bytes
      ,r.cpu_time
      ,r.user_io_wait_time
      ,r.queuing_time
      ,r.application_wait_time
      ,r.concurrency_wait_time
      ,r.cluster_wait_time
      ,r.plsql_exec_time
      ,r.java_exec_time
      ,(select owner||'.'||object_name||nullif('.'||p.PROCEDURE_NAME,'.') from dba_procedures p where p.OBJECT_ID=r.PLSQL_OBJECT_ID and p.SUBPROGRAM_ID = r.PLSQL_SUBPROGRAM_ID) as pl_obj
      ,(select owner||'.'||object_name||nullif('.'||p.PROCEDURE_NAME,'.') from dba_procedures p where p.OBJECT_ID=r.PLSQL_ENTRY_OBJECT_ID and p.SUBPROGRAM_ID = r.PLSQL_ENTRY_SUBPROGRAM_ID) as ple_obj
from v$sql_monitor r
where upper(r.USERNAME) like upper('%&1%')
  and r.status = 'EXECUTING'
order by username,program,sql_exec_start,elapsed_time desc,cpu_time desc,user_io_wait_time desc
/
col username clear;
col program  clear;
col sql_id   clear;
col status   clear;
col qtext    clear;
