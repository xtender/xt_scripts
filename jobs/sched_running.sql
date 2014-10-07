col owner               format a30;
col "JOB_NAME/SUBNAME"  format a45;
col inst_id             format 999999;
col event               format a64;
col sql_id              format a13;
col sql_exec_start      format a19;
col elapsed_time        format a17;
col cpu_used            format a18;
col SLAVE_OS_PROCESS_ID format a12 heading slave_os_pid;
col SLAVE_OS_PID        format a12;

-------------------- ------------------------------ ------------------------------ --------------------------------- --------------- ---------- ---------- ------ ---------------- ----------------- -
select 
  jr.OWNER
 ,jr.JOB_NAME||nvl2(jr.JOB_SUBNAME,'('||jr.JOB_SUBNAME||')','') "JOB_NAME/SUBNAME"
 ,s.inst_id
 ,jr.session_id         as sid
 ,s.serial#
 ,s.event
 ,s.sql_id
 ,s.sql_exec_start
 ,jr.ELAPSED_TIME
 ,jr.CPU_USED
 ,jr.LOG_ID
 ,jr.SLAVE_PROCESS_ID    as "SLAVE_PID"
 ,jr.SLAVE_OS_PROCESS_ID as "SLAVE_OS_PID"
 ,jr.JOB_STYLE
 ,jr.detached
 ,jr.resource_consumer_group
from dba_scheduler_running_jobs jr
    ,gv$session s
where jr.session_id = s.sid
  and jr.RUNNING_INSTANCE = s.inst_id
;
col owner               clear;
col "JOB_NAME/SUBNAME"  clear;
col event               clear;
col sql_id              clear;
col sql_exec_start      clear;
col elapsed_time        clear;
col cpu_used            clear;
col slave_os_process_id clear;
col slave_os_pid        clear;
