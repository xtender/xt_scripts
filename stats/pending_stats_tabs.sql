prompt *** Pending stats groupped by owner,table_name,partition_name
col owner          for a30;
col table_name     for a30;
col partition_name for a30;
select 
   owner
  ,table_name
  ,partition_name
  ,sum(num_rows)       num_rows
  ,sum(blocks)         blocks
  ,count(*)            cnt
  ,min(last_analyzed)  last_analyzed_min
  ,min(last_analyzed)  last_analyzed_max
from dba_tab_pending_stats st
group by
   owner
  ,table_name
  ,partition_name
order by 1,2,3
;
col owner          clear;
col table_name     clear;
col partition_name clear;
