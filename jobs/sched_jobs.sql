col owner               format a30;
col "JOB_NAME/SUBNAME"  format a40;
col last_start_date     format a45;
col last_run_duration   format a16;
col next_run_date       format a45;

-------------------- ------------------------------ ------------------------------ --------------------------------- --------------- ---------- ---------- ------ ---------------- ----------------- -
select 
  jr.OWNER
 ,jr.JOB_NAME||nvl2(jr.JOB_SUBNAME,'('||jr.JOB_SUBNAME||')','') "JOB_NAME/SUBNAME"
 ,last_start_date
 ,cast(last_run_duration AS INTERVAL DAY(1) TO SECOND(3)) as last_run_duration
 ,next_run_date
from dba_scheduler_jobs jr
where 1=1
;
col owner               clear;
col "JOB_NAME/SUBNAME"  clear;