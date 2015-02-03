@inc/input_vars_init;
select 
   st.plan_hash_value                                             as plan_hv
  ,min(snap_id)                                                   as snap_min
  ,max(snap_id)                                                   as snap_max
  ,avg(st.elapsed_time_delta/1e6/nullif(st.executions_delta,0))   as ela_avg
  ,max(st.elapsed_time_delta/1e6/nullif(st.executions_delta,0))   as ela_max
  ,min(st.elapsed_time_delta/1e6/nullif(st.executions_delta,0))   as ela_min
from dba_hist_sqlstat st
where sql_id='&1'
group by st.plan_hash_value
order by snap_max desc, ela_avg
/
@inc/input_vars_undef;
