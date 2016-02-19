prompt *** Show last autotasks runs.
prompt * Usage: @stats/autotasks/last [N]
@inc/input_vars_init;
prompt Last N runs:;
col client_name        for a25 trunc;
col window_name        for a18;
col window_start_time  for a35;
col job_status         for a12;
col job_start_time     for a35;
col job_duration       for a15;
select * 
from (select client_name
           , window_name
           , window_start_time
           , job_status
           , job_start_time
           , job_duration
           , job_error
      from dba_autotask_job_history 
      order by window_start_time desc
     ) 
where rownum<=decode('&1',null,10,'&1');

col client_name        clear;
col window_name        clear;
col window_start_time  clear;
col job_status         clear;
col job_start_time     clear;
col job_duration       clear;
@inc/input_vars_undef;
