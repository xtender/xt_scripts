col job_name      format a30;
col JOB_SUBNAME   format a30;
col elapsed_time  format a17;
col SLAVE_OS_PROCESS_ID format a12 heading slave_os_pid;
col SLAVE_OS_PID  format a12;
-------------------- ------------------------------ ------------------------------ --------------------------------- --------------- ---------- ---------- ------ ---------------- ----------------- -
select 
  jr.OWNER
 ,jr.JOB_NAME
 ,jr.JOB_SUBNAME
 ,jr.JOB_STYLE
 ,jr.detached
 ,jr.session_id
 ,jr.SLAVE_PROCESS_ID    as "SLAVE_PID"
 ,jr.SLAVE_OS_PROCESS_ID as "SLAVE_OS_PID"
 ,jr.RUNNING_INSTANCE
 ,jr.ELAPSED_TIME
 ,jr.CPU_USED
 ,jr.LOG_ID
 ,jr.resource_consumer_group
from dba_scheduler_running_jobs jr
;
col job_name       clear;
col JOB_SUBNAME    clear;
col elapsed_time   clear;
