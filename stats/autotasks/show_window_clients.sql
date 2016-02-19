col WINDOW_NAME      for a18;
col AUTOTASK_STATUS  for a15;
col OPTIMIZER_STATS  for a15;
col SEGMENT_ADVISOR  for a15;
col SQL_TUNE_ADVISOR for a16;
col HEALTH_MONITOR   for a15;
col WINDOW_NEXT_TIME for a19;
col repeat_interval  for a60;
col duration         for a15;
col enabled          for a7;
select wc.WINDOW_NAME
      ,wc.AUTOTASK_STATUS
      ,wc.OPTIMIZER_STATS
      ,wc.SEGMENT_ADVISOR
      ,wc.SQL_TUNE_ADVISOR
      ,wc.HEALTH_MONITOR
      ,to_char(wc.WINDOW_NEXT_TIME,'yyyy-mm-dd hh24:mi:ss') as WINDOW_NEXT_TIME
      ,w.repeat_interval
      ,w.duration
      ,w.ENABLED
from dba_autotask_window_clients wc
    ,dba_scheduler_windows w
where wc.WINDOW_NAME = w.WINDOW_NAME(+);
col WINDOW_NAME        clear;
col AUTOTASK_STATUS    clear;
col OPTIMIZER_STATS    clear;
col SEGMENT_ADVISOR    clear;
col SQL_TUNE_ADVISOR   clear;
col HEALTH_MONITOR     clear;
col WINDOW_NEXT_TIME   clear;
col repeat_interval    clear;
col duration           clear;
col enabled            clear;
