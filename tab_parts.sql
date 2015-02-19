prompt *** Show table partitions
prompt * Usage: @tab_parts tab_name_mask [tab_owner_mask]

@inc/input_vars_init;

col table_owner        for a30;
col table_name         for a30;
col partition_position for 999 heading "#";
col partition_name     for a30;
col subpartition_count for 999 heading SUBPARTS;
col high_value         for a120;
col tablespace_name    for a12;
col segment_created    for a3;

select
    p.table_owner
   ,p.table_name
   ,p.partition_position
   ,p.partition_name
   ,p.subpartition_count
   ,p.tablespace_name
   ,p.num_rows
   ,p.blocks
   ,to_date(p.last_analyzed,'yyyy-mm-dd hh24:mi:ss') as last_analyzed
   ,p.segment_created
   ,p.high_value
from 
   xmltable(
      '/ROWSET/ROW'
      passing 
         dbms_xmlgen.getXMLType(q'[
            select 
                p.table_owner
               ,p.table_name
               ,p.partition_position
               ,p.partition_name
               ,p.subpartition_count
               ,p.high_value
               ,p.tablespace_name
               ,p.num_rows
               ,p.blocks
               ,to_char(p.last_analyzed,'yyyy-mm-dd hh24:mi:ss') as last_analyzed
               ,p.segment_created
            from dba_tab_partitions p 
            where p.table_owner like upper(nvl('&2','%'))
              and p.table_name  like upper(nvl('&1','%'))
            order by 1,2,3]'
       )
     columns
          table_owner
         ,table_name
         ,partition_position  int
         ,partition_name
         ,subpartition_count  int
         ,high_value
         ,tablespace_name
         ,num_rows            int
         ,blocks              int
         ,last_analyzed       
         ,segment_created
    ) p
order by 1,2,3
/
col table_owner        clear;
col table_name         clear;
col partition_position clear;
col partition_name     clear;
col subpartition_count clear;
col high_value         clear;
col tablespace_name    clear;
col segment_created    clear;
