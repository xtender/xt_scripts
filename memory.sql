col component for a60;
select 
   component
  ,current_size /1024/1024 "curr.size(MB)"
  ,min_size     /1024/1024 "min.size(MB)"
  ,max_size     /1024/1024 "max.size(MB)"
  ,dc.last_oper_type
  ,dc.last_oper_time
from v$memory_dynamic_components dc;
col component clear;