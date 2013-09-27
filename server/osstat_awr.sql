prompt *** =======================================================================
prompt *** dba_hist_osstat for period;
prompt *** Usage: @server/osstat_awr "2013-01-21 00:00:00" "2013-01-22 11:00:00";
prompt *** =======================================================================
col dt format a16;

with t as (
         select to_char(s.begin_interval_time,'yyyy-mm-dd hh24:mi') dt
               ,stat_name
               ,value
         from dba_hist_osstat o
             ,dba_hist_snapshot s
         where o.snap_id=s.snap_id
         and o.instance_number=s.instance_number
         and s.begin_interval_time between to_date('&1','yyyy-mm-dd hh24:mi:ss')
                                       and to_date('&2','yyyy-mm-dd hh24:mi:ss')
)
select
*
from t
pivot (
   max(t.value)
   for stat_name in ( q'[NUM_CPUS]'
                     ,q'[IDLE_TIME]'
                     ,q'[BUSY_TIME]'
                     ,q'[USER_TIME]'
                     ,q'[SYS_TIME]'
                     ,q'[IOWAIT_TIME]'
                     ,q'[AVG_IDLE_TIME]'
                     ,q'[AVG_BUSY_TIME]'
                     ,q'[AVG_USER_TIME]'
                     ,q'[AVG_SYS_TIME]'
                     ,q'[AVG_IOWAIT_TIME]'
                     ,q'[OS_CPU_WAIT_TIME]'
                     ,q'[RSRC_MGR_CPU_WAIT_TIME]'
                     ,q'[LOAD]'
                     ,q'[NUM_CPU_CORES]'
                     ,q'[NUM_CPU_SOCKETS]'
                     ,q'[PHYSICAL_MEMORY_BYTES]'
                     ,q'[VM_IN_BYTES]'
                     ,q'[VM_OUT_BYTES]'
                    )
)
order by dt
/

col dt clear;
undef 1 2;
