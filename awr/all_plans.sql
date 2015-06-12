@inc/input_vars_init;
col snap_min_time for a19;
col snap_max_time for a19;

with v as (
   select 
      st.dbid
     ,st.plan_hash_value                                             as plan_hv
     ,min(snap_id)                                                   as snap_min
     ,max(snap_id)                                                   as snap_max
     ,count(distinct snap_id)                                        as snaps
     ,sum(st.executions_delta)                                       as execs
     ,avg(st.elapsed_time_delta/1e6/nullif(st.executions_delta,0))   as ela_avg
     ,max(st.elapsed_time_delta/1e6/nullif(st.executions_delta,0))   as ela_max
     ,min(st.elapsed_time_delta/1e6/nullif(st.executions_delta,0))   as ela_min
   from dba_hist_sqlstat st
   where sql_id='&1'
   and dbid in (select i.dbid from dba_hist_database_instance i)
   group by st.dbid,st.plan_hash_value
   order by snap_max desc, ela_avg
)
select
    dbid
   ,plan_hv
   ,snap_min
   ,snap_max
   ,(select to_char(begin_interval_time,'yyyy-mm-dd hh24:mi')
     from dba_hist_snapshot sn 
     where sn.snap_id = v.snap_min
       and sn.dbid    = v.dbid)                                    as snap_min_time
   ,(select to_char(begin_interval_time,'yyyy-mm-dd hh24:mi') 
     from dba_hist_snapshot sn 
     where sn.snap_id = v.snap_max
       and sn.dbid    = v.dbid)                                    as snap_max_time
   ,snaps
   ,execs
   ,ela_avg
   ,ela_max 
   ,ela_min 
from v
/
@inc/input_vars_undef;

