prompt *** Pending columns stats
accept _owner prompt "Owner mask[%]: " default "%";
accept _table prompt "Table mask[%]: " default "%";

col owner          for a30;
col table_name     for a30;
col partition      for a30;
col subpartition   for a30;
col column_name    for a30;

select 
    OWNER
   ,TABLE_NAME
   ,PARTITION_NAME     as "PARTITION"
   ,SUBPARTITION_NAME  as "SUBPARTITION"
   ,COLUMN_NAME
   ,LAST_ANALYZED
   ,NUM_DISTINCT
   ,DENSITY
   ,NUM_NULLS
   ,AVG_COL_LEN
   ,SAMPLE_SIZE
   ,LOW_VALUE
   ,HIGH_VALUE
from dba_col_pending_stats cps
where cps.owner      like '&_owner'
  and cps.table_name like '&_table'
;
col owner          clear;
col table_name     clear;
col partition      clear;
col subpartition   clear;
col column_name    clear;
