select 
   sn.snap_id
  ,sn.dbid
  ,sn.instance_number inst
  ,to_char(sn.begin_interval_time,'yyyy-mm-dd hh24:mi:ss') begin_interval
  ,to_char(sn.end_interval_time  ,'yyyy-mm-dd hh24:mi:ss') end_interval
  ,sn.error_count
  ,sn.snap_timezone
from dba_hist_snapshot sn
where snap_id=&1;