@inc/input_vars_init;
select
    t.owner
   ,t.table_name
   ,t.PARTITION_NAME
   ,t.PARTITION_POSITION
   ,t.stattype_locked
   ,t.stale_stats
   ,t.global_stats
   ,t.user_stats
   ,t.NUM_ROWS
   ,t.BLOCKS
   ,t.EMPTY_BLOCKS
   ,t.AVG_ROW_LEN
   ,t.AVG_SPACE
   ,t.LAST_ANALYZED 
from dba_tab_statistics t 
where t.owner like nvl(upper('&1'),'%')
and (t.LAST_ANALYZED is null or t.stale_stats='YES');
@inc/input_vars_undef;
