col tab_name      for a45;
col owner         for a20;
col segment_type  for a15;
col segment_name  for a30;
col MBytes        for 99999;

with 
seg as (
      select 
        owner
       ,segment_type
       ,segment_name
       ,bytes
       ,decode(segment_type
          ,'TABLE'
              ,ts.owner||'.'||ts.segment_name
          ,'TABLE PARTITION'
              ,ts.owner||'.'||ts.segment_name
          ,'TABLE SUBPARTITION'
              ,ts.owner||'.'||ts.segment_name
          ,'LOBINDEX'  
              ,(select l.owner||'.'||table_name tab from dba_lobs l where l.owner = ts.owner and l.index_name = ts.segment_name)
          ,'LOBSEGMENT'
              ,(select l.owner||'.'||table_name tab from dba_lobs l where l.owner = ts.owner and l.segment_name = ts.segment_name)
          ,'LOB PARTITION'
              ,(select l.owner||'.'||table_name tab from dba_lobs l where l.owner = ts.owner and l.segment_name = ts.segment_name)
          ,'INDEX'
              ,(select i.table_owner||'.'||i.table_name from dba_indexes i where i.owner=ts.owner and i.index_name=ts.segment_name)
          ,'INDEX PARTITION'
              ,(select i.table_owner||'.'||i.table_name from dba_indexes i where i.owner=ts.owner and i.index_name=ts.segment_name)
          ,'CLUSTER'
              ,'CLUSTER: '||ts.owner||'.'||ts.segment_name
          ,'NESTED TABLE'
              ,(select nt.owner||'.'||nt.parent_table_name from dba_nested_tables nt where nt.table_name=ts.segment_name and nt.owner=ts.owner)
          ,'N/A'
          ) tab_name
      from dba_segments ts
      where ts.segment_type not in ('SYSTEM STATISTICS','TYPE2 UNDO','ROLLBACK')
)
,top_seg as (
   select *
   from (
      select *
      from seg   
      order by bytes desc
   )
   where rownum<=&N
)
select
   tab_name
  ,owner
  ,segment_type
  ,segment_name
  ,bytes/1024/1024 MBytes
from top_seg ts
/
col tab_name      clear;
col owner         clear;
col segment_type  clear;
col segment_name  clear;
col MBytes        clear;
