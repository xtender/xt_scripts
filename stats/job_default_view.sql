col client_name     for a40 trunc;
col status          for a7;
col window_group    for a40 trunc;
col consumer_group  for a40 trunc;

select client_name
      ,status
      ,window_group
      ,consumer_group
 from dba_autotask_client 
where client_name='auto optimizer stats collection'
/

col WINDOW_NAME     for a18;
col OPTIMIZER_STATS for a15;
select wc.WINDOW_NAME
      ,wc.WINDOW_ACTIVE
      ,wc.AUTOTASK_STATUS
      ,wc.OPTIMIZER_STATS
      ,wc.WINDOW_NEXT_TIME
from dba_autotask_window_clients wc;

prompt Last 5 runs:;
col window_start_time for a30;
col job_start_time    for a30;
select * 
from (select client_name, window_name, window_start_time, job_status, job_start_time, job_duration, job_error
      from dba_autotask_job_history 
      order by window_start_time desc
     ) 
where rownum<=10;

col OPTIMIZER_STATS clear;
col WINDOW_NAME     clear;

col client_name     clear;
col status          clear;
col window_group    clear;
col consumer_group  clear;

col window_start_time clear;
col job_start_time    clear;
