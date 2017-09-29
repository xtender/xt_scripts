@inc/input_vars_init.sql

define tab_owner="nvl(upper('&2'),'%')"
define tab_name="&1"

col owner           for a15 new_val _tab_owner
col table_name      for a30 new_val _tab_name
col partition_name  for a20
col index_name      for a30
col st_lock         for a7
col #               for 999
col cols            for a150;
prompt ------------- tab stats -------------------;
select
    t.owner
   ,t.table_name
   ,t.PARTITION_NAME
   ,t.PARTITION_POSITION as "#"
   ,t.stattype_locked as st_lock
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
where  
      t.owner      like &tab_owner
  and t.table_name = upper('&tab_name');
prompt ;
prompt ------------- ind stats ------------------;
select 
    ix.owner
   ,ix.index_name
   ,ix.num_rows
   ,ix.distinct_keys
   ,ix.blevel
   ,ix.leaf_blocks
   ,ix.clustering_factor as cl_factor
   ,ix.last_analyzed
   ,ix.global_stats
   ,ix.user_stats
   ,(select ltrim(max(sys_connect_by_path(ic.column_name,',')),',')
     from dba_ind_columns ic 
     start with ic.INDEX_OWNER=ix.owner
            and ic.INDEX_NAME = ix.index_name
            and ic.COLUMN_POSITION=1
     connect by ic.INDEX_OWNER=ix.owner
            and ic.INDEX_NAME = ix.index_name
            and ic.COLUMN_POSITION= prior ic.COLUMN_POSITION+1
     ) cols
from dba_indexes ix 
where 
      ix.table_owner = '&_tab_owner'
  and ix.table_name  = '&_tab_name';
prompt ;
prompt ------------- col stats   -----------------;
undef tab_name tab_owner _tab_name _tab_owner;
col owner           clear;
col table_name      clear;
col partition_name  clear;
col index_name      clear;
col st_lock         clear;
col #               clear;
col cols            clear;
@inc/input_vars_undef.sql