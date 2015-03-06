col force_matching_signature new_value sign_force for a25;
col exact_matching_signature new_value sign_exact for a25;
col profile for a30;

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
     s.force_matching_signature = &1
  or s.exact_matching_signature = &1
order by s.plan_hash_value,s.sql_id;

col profile clear;