accept time_start   prompt "Start time[yyyy-mm-dd hh24:mi:ss]: ";
accept time_end     prompt "End   time[yyyy-mm-dd hh24:mi:ss]: ";
col db_time                     for tm9;
col db_cpu                      for tm9;
col user_io_wait_time           for tm9;
col sql_execute_elapsed_time    for tm9;


with xt_awr_temp_log as (
      select *
      from 
            (
            select 
               sn.snap_id
              ,trunc(sn.begin_interval_time,'hh') beg_time
              ,st.stat_name
              ,sum(st.value-st0.value) value
            from dba_hist_snapshot sn
               , dba_hist_service_stat st
               , dba_hist_service_stat st0
            where sn.dbid            = st.dbid
              and sn.snap_id         = st.snap_id
              and sn.instance_number = st.instance_number
--              and extract(hour from sn.begin_interval_time ) between 8 and 11
              and to_char(sn.begin_interval_time,'fmDAY','NLS_DATE_LANGUAGE = american') not in ('SUNDAY','SATURDAY')
              and sn.end_interval_time   >= timestamp'&time_start'
              and sn.begin_interval_time <= timestamp'&time_end'
              and st.dbid            = st0.dbid
              and st.snap_id-1       = st0.snap_id
              and st.instance_number = st0.instance_number
              and st.stat_name       = st0.stat_name
              and st.stat_name in (
                                  'user rollbacks'
                                 ,'user commits'
                                 ,'physical writes'
                                 ,'opened cursors cumulative'
                                 ,'user calls'
                                 ,'physical reads'
                                 ,'db block changes'
                                 ,'execute count'
                                 ,'parse time elapsed'
                                 ,'application wait time'
                                 ,'session logical reads'
                                 ,'redo size'
                                 ,'DB CPU'
                                 ,'user I/O wait time'
                                 ,'sql execute elapsed time'
                                 ,'DB time'
                                 )
            group by
               sn.snap_id
              ,trunc(sn.begin_interval_time,'hh')
              ,st.stat_name
            )
      pivot (
        sum(value)
        for stat_name in (
                            'DB time'                    as  DB_time
                           ,'DB CPU'                     as  DB_CPU
                           ,'user I/O wait time'         as  user_IO_wait_time
                           ,'sql execute elapsed time'   as  sql_execute_elapsed_time
                           ,'user rollbacks'             as  user_rollbacks
                           ,'user commits'               as  user_commits
                           ,'session logical reads'      as  session_logical_reads
                           ,'physical writes'            as  physical_writes
                           ,'physical reads'             as  physical_reads
                           ,'db block changes'           as  db_block_changes
                           ,'redo size'                  as  redo_size
                           ,'opened cursors cumulative'  as  opened_cursors_cumulative
                           ,'user calls'                 as  user_calls
                           ,'execute count'              as  execute_count
                           ,'parse time elapsed'         as  parse_time_elapsed
                           ,'application wait time'      as  application_wait_time
                           )
      )
)
select l.*
from xt_awr_temp_log l
order by beg_time desc
/