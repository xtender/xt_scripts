col client_name        for a35 trunc;
col status             for a9;
col window_group       for a20 trunc;
col consumer_group     for a30 trunc;
col mean_job_duration  for a23 trunc;
col max_dur_last7days  for a17 trunc;
col max_dur_last30days for a17 trunc;
select atc.client_name
      ,atc.status
      ,atc.window_group
      ,atc.consumer_group
      ,atc.mean_job_duration
      ,atc.max_duration_last_7_days  as max_dur_last7days
      ,atc.max_duration_last_30_days as max_dur_last30days
 from dba_autotask_client  atc
where 1=1
--atc.client_name='auto optimizer stats collection'
/
col client_name        clear;
col status             clear;
col window_group       clear;
col consumer_group     clear;
col mean_job_duration  clear;
col max_dur_last7days  clear;
col max_dur_last30days clear;
