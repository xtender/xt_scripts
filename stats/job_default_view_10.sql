col JOB_NAME        for a16;
col REPEAT_INTERVAL for a100;
select job_name
      ,j.schedule_type
      ,j.enabled
      ,j.state
      ,g.window_group_name
      ,g.enabled           as group_enabled
      ,wm.window_name
      ,w.repeat_interval
      ,w.duration
      ,w.enabled           as window_enabled
from dba_scheduler_jobs j
    ,dba_scheduler_window_groups g
    ,dba_scheduler_wingroup_members wm
    ,dba_scheduler_windows w
where j.owner='SYS' 
  and j.job_name='GATHER_STATS_JOB'
  and j.schedule_name = g.window_group_name
  and g.window_group_name = wm.window_group_name
  and wm.window_name = w.window_name
/
col JOB_NAME        clear;
col REPEAT_INTERVAL clear;
