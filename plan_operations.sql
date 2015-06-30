col operation_name for a40;

select distinct
   operation_id
  ,operation_name
from DBA_HIST_PLAN_OPERATION_NAME
where upper(operation_name) like upper('%&1%')
order by 1;

col operation_name clear;
