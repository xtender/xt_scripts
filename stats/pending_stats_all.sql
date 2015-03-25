accept _owner prompt "Owner mask[%]: " default "%";
accept _table prompt "Table mask[%]: " default "%";

col owner for a30;
col table for a30;
col obj_types for a15;

select owner
      ,table_name as "TABLE"
      ,to_char(wm_concat(distinct obj_type)) as obj_types
from (
      select distinct owner,table_name,'TAB' obj_type from DBA_TAB_PENDING_STATS
      union all
      select distinct owner,table_name,'COL' obj_type from DBA_COL_PENDING_STATS
      union all
      select distinct owner,table_name,'IND' obj_type from DBA_IND_PENDING_STATS
      union all
      select distinct owner,table_name,'HST' obj_type from DBA_TAB_HISTGRM_PENDING_STATS
)
where owner      like '&_owner'
  and table_name like '&_table'
group by owner,table_name
/
col obj_types clear;
