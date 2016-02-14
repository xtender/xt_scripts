prompt ====================================================================
prompt *** Find lobs by table, column, segment or index names
prompt * Usage @lob_by_name mask [owner_mask]
prompt ====================================================================
@inc/input_vars_init;
col owner           for a15;
col table_name      for a30;
col column_name     for a30;
col segment_name    for a30;
col tablespace_name for a12 heading tablespace;
col index_name      for a30;
col cache           for a5;
col logging         for a7;
col compression     for a11;
col deduplication   for a5 heading dedup;
col in_row          for a6;
col partitioned     for a4;
col securefile      for a9;
col segment_created for a11 heading seg_created;
col retention_type  for a8 heading ret_type;
col retention_value for a7 heading ret_val;
select
  l.owner        
 ,l.table_name  
 ,l.column_name 
 ,l.segment_name
 ,l.tablespace_name  
 ,l.index_name  
 ,l.chunk
 ,l.retention
 ,l.cache
 ,l.logging
 ,l.compression 
 ,l.deduplication
 ,l.in_row         
 ,l.partitioned    
 ,l.securefile     
 ,l.segment_created
 ,l.retention_type 
 ,l.retention_value
from dba_lobs l 
where
  (
      l.table_name   like upper('%&1%')
   or l.column_name  like upper('%&1%')
   or l.segment_name like upper('%&1%')
   or l.index_name   like upper('%&1%')
  )
  and l.owner like nvl(upper('%&2%'),'%')
/
col owner           clear;
col table_name      clear;
col column_name     clear;
col segment_name    clear;
col tablespace_name clear;
col index_name      clear;
col cache           clear;
col logging         clear;
col compression     clear;
col deduplication   clear;
col in_row          clear;
col partitioned     clear;
col securefile      clear;
col segment_created clear;
col retention_type  clear;
col retention_value clear;
