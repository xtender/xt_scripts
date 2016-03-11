col force_matching_signature new_value sign_force for a25
col exact_matching_signature new_value sign_exact for a25
col profile for a30;

select 
   to_char(a.force_matching_signature,'tm9') force_matching_signature
  ,to_char(a.exact_matching_signature,'tm9') exact_matching_signature
from v$sql_monitor a 
where a.sql_id='&1';

select sql_id
      ,child_number
      ,plan_hash_value
      ,elapsed_time/nullif(executions,0)/1e6     ela_exe
      ,executions                                cnt
      ,sql_profile                               profile
      ,to_char(s.force_matching_signature,'tm9') force_matching_signature
      ,to_char(s.exact_matching_signature,'tm9') exact_matching_signature
from v$sql s
where 
     s.force_matching_signature = &sign_force
  or s.exact_matching_signature = &sign_exact
order by s.plan_hash_value,s.sql_id;

col profile clear;