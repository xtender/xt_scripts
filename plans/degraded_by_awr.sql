with 
  last_day as (
      select-- inline
          row_number() over(order by sum(ELAPSED_TIME_DELTA) desc)                     top_n
         ,sql_id                                                                       sql_id
         ,row_number() over(partition by sql_id order by sum(ELAPSED_TIME_DELTA) desc) plan#
         ,plan_hash_value                                                              plan_hv
         ,count(distinct plan_hash_value) over(partition by max(sql_id))               plans_cnt
         ,count(distinct SNAP_ID)                                                      snaps_cnt
         ,min(snap_id)                                                                 snap_min
         ,max(snap_id)                                                                 snap_max
         ,count(*)                                                                     cnt
         ,avg(OPTIMIZER_COST)                                                          opt_cost
         ,cast(wm_concat(distinct OPTIMIZER_MODE) as varchar2(300))                    opt_modes
         ,sum(EXECUTIONS_DELTA)                                                        execs
         ,avg(ELAPSED_TIME_DELTA/EXECUTIONS_DELTA) /1e6                                elaexe
         ,min(ELAPSED_TIME_DELTA/EXECUTIONS_DELTA) /1e6                                elaexec_min
         ,max(ELAPSED_TIME_DELTA/EXECUTIONS_DELTA) /1e6                                elaexec_max
         ,sum(ELAPSED_TIME_DELTA)                  /1e6                                elapsed_secs
         ,avg(IOWAIT_DELTA/EXECUTIONS_DELTA)       /1e6                                iowait
         ,avg(CPU_TIME_DELTA/EXECUTIONS_DELTA)     /1e6                                cpu_time
         ,avg(BUFFER_GETS_DELTA              /EXECUTIONS_DELTA)                        buff_gets
         ,avg(DISK_READS_DELTA               /EXECUTIONS_DELTA)                        disk_reads
         ,avg(ROWS_PROCESSED_DELTA           /EXECUTIONS_DELTA)                        rows_avg
         ----------------------------------------------------------------------------
         ,avg(SHARABLE_MEM)                                                            SHARABLE_MEM
         ,max(LOADED_VERSIONS)                                                         LOADED_VERSIONS
         ,max(VERSION_COUNT)                                                           VERSION_COUNT
         ,min(SQL_PROFILE)                                                             SQL_PROFILE
         --,count(SQL_PROFILE)                                                           SQL_PROFILE_CNT
         --,avg(FETCHES_DELTA                  /EXECUTIONS_DELTA)                        fetches
         --,avg(SORTS_DELTA                    /EXECUTIONS_DELTA)                        sorts
         ,avg(CLWAIT_DELTA                   /EXECUTIONS_DELTA)/1e6                    CLWAIT
         ,avg(APWAIT_DELTA                   /EXECUTIONS_DELTA)/1e6                    APWAIT
         ,avg(CCWAIT_DELTA                   /EXECUTIONS_DELTA)/1e6                    CCWAIT
         ,avg(PLSEXEC_TIME_DELTA             /EXECUTIONS_DELTA)/1e6                    plsql_time
         ,avg(JAVEXEC_TIME_DELTA             /EXECUTIONS_DELTA)/1e6                    java_time
         ----------------------------------------------------------------------------
         ,avg(PHYSICAL_READ_REQUESTS_DELTA   /EXECUTIONS_DELTA)                        phy_r_reqs
         ,avg(PHYSICAL_READ_BYTES_DELTA      /EXECUTIONS_DELTA)                        phy_r_bytes
         ,avg(PHYSICAL_WRITE_REQUESTS_DELTA  /EXECUTIONS_DELTA)                        phy_w_reqs
         ,avg(PHYSICAL_WRITE_BYTES_DELTA     /EXECUTIONS_DELTA)                        phy_w_bytes
         ,avg(DIRECT_WRITES_DELTA            /EXECUTIONS_DELTA)                        dir_writes
         ,avg(OPTIMIZED_PHYSICAL_READS_DELTA /EXECUTIONS_DELTA)                        opt_phy_reads
         ----------------------------------------------------------------------------
         --,avg(IO_OFFLOAD_ELIG_BYTES_DELTA    /EXECUTIONS_DELTA)             io_offload_elig
         --,avg(IO_INTERCONNECT_BYTES_DELTA    /EXECUTIONS_DELTA)             io_interconnect
         --,avg(CELL_UNCOMPRESSED_BYTES_DELTA  /EXECUTIONS_DELTA)             cell_uncompr_bytes
         --,avg(IO_OFFLOAD_RETURN_BYTES_DELTA  /EXECUTIONS_DELTA)             io_offload_return

      from dba_hist_sqlstat
      where executions_delta>0
        and dbid in (select/*+ precompute_subquery */ db.dbid from v$database db)
        and snap_id >= (select min(sn.snap_id) from dba_hist_snapshot sn where sn.end_interval_time>cast(trunc(sysdate) as timestamp))
      group by sql_id
              ,plan_hash_value 
  )
 ,prev_data as (
      select-- inline
          sql_id                                                            sql_id
         ,plan_hash_value                                                   plan_hv
         ,count(distinct plan_hash_value) over(partition by max(sql_id))    plans_cnt
         ,count(distinct SNAP_ID)                                           snaps_cnt
         ,min(snap_id)                                                      snap_min
         ,max(snap_id)                                                      snap_max
         ,sum(EXECUTIONS_DELTA)                                             execs
         ,avg(ELAPSED_TIME_DELTA/EXECUTIONS_DELTA) /1e6                     elaexe
         ,min(ELAPSED_TIME_DELTA/EXECUTIONS_DELTA) /1e6                     elaexec_min
         ,max(ELAPSED_TIME_DELTA/EXECUTIONS_DELTA) /1e6                     elaexec_max
         ,avg(IOWAIT_DELTA/EXECUTIONS_DELTA)       /1e6                     iowait
         ,avg(CPU_TIME_DELTA/EXECUTIONS_DELTA)     /1e6                     cpu_time
         ,avg(BUFFER_GETS_DELTA              /EXECUTIONS_DELTA)             buff_gets
         ,min(SQL_PROFILE)                                                  SQL_PROFILE
      from dba_hist_sqlstat
      where executions_delta>0
        and dbid in (select/*+ precompute_subquery */ db.dbid from v$database db)
        and snap_id < (select min(sn.snap_id) from dba_hist_snapshot sn where sn.end_interval_time>cast(trunc(sysdate) as timestamp))
      group by sql_id
              ,plan_hash_value 
  )
 ,sqls_filtr as (
      select l.sql_id
      from last_day l
      group by l.sql_id
      having exists(select 1 from prev_data p where p.sql_id=l.sql_id and p.elaexe<min(l.elaexe) and p.plan_hv!)
  )
--------------------------------------
select
   top_n          , sql_id            , plan#            , plan_hv          , plans_cnt        , snaps_cnt        , snap_min
  ,snap_max       , cnt               , opt_cost         , opt_modes        , execs            , elaexe           , elaexec_min
  ,elaexec_max    , elapsed_secs      , iowait           , cpu_time         , buff_gets        , disk_reads       , rows_avg
  ,SHARABLE_MEM   , LOADED_VERSIONS   , VERSION_COUNT    , SQL_PROFILE      , CLWAIT           , APWAIT           , CCWAIT
  ,plsql_time     , java_time         , phy_r_reqs       , phy_r_bytes      , phy_w_reqs       , phy_w_bytes      , dir_writes
  ,opt_phy_reads
from last_day l 
where plans_cnt>1 or l.sql_id in (select f.sql_id from sqls_filtr f)
--------------------------------------
union all
--------------------------------------
select
   null           , sql_id            , null             , plan_hv          , plans_cnt        , snaps_cnt        , snap_min
 , snap_max       , null              , null             , null             , execs            , elaexe           , elaexec_min
 , elaexec_max    , null              , iowait           , cpu_time         , buff_gets        , null             , null
 , null           , null              , null             , SQL_PROFILE      , null             , null             , null
 , null           , null              , null             , null             , null             , null             , null
 , null
from prev_data p
where
     p.sql_id in (select f.sql_id from sqls_filtr f)
order by 2,3 nulls last

