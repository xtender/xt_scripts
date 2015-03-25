@inc/input_vars_init;
col force_matching_signature new_value sign_force for a25
col exact_matching_signature new_value sign_exact for a25
col profile for a30;

select to_char(sn.begin_interval_time,'yyyy-mm-dd hh24:mi') beg_time
      ,sn.snap_id
      ,s.sql_id
      ,s.plan_hash_value
      ,s.elapsed_time_delta/nullif(s.executions_delta,0)/1e6  ela_exe
      ,s.executions_delta                                     cnt
      ,s.sql_profile                                          profile
      ,to_char(s.force_matching_signature,'tm9')              force_matching_signature
from dba_hist_sqlstat s
    ,dba_hist_snapshot sn
where 
      s.force_matching_signature in (&1,&2)
  and s.dbid                     = sn.dbid
  and s.snap_id                  = sn.snap_id
  and s.instance_number          = sn.instance_number
order by sn.snap_id desc, s.plan_hash_value, s.sql_id;

col profile clear;
@inc/input_vars_undef;
