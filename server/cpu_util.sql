col begin_time  for a19;
col end_time    for a8;
col sec         for 999.00;
col metric_name for a28;
col value       for 9999999.00;
select to_char(begin_time,'yyyy-mm-dd hh24:mi:ss') begin_time
      ,to_char(end_time,'hh24:mi:ss') end_time
      ,intsize_csec/100 sec
      ,metric_name
      ,to_char(value,'9999990.00') value
      ,metric_unit
from v$sysmetric 
where metric_name like '%CPU%';
col begin_time  clear;
col end_time    clear;
col sec         clear;
col metric_name clear;
col value       clear;
