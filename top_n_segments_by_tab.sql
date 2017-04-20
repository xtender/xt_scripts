col tab_name      for a45;
col owner         for a20;
col segment_type  for a20;
col segment_name  for a30;
col MBytes        for 999999;
col MBytes_tab    for 999999;
break on tab_name on MBytes_tab skip 1;

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
              ,(select nt.parent_table_name from dba_nested_tables nt where nt.table_name=ts.segment_name and nt.owner=ts.owner)
          ,'N/A'
          ) tab_name
      from dba_segments ts
      where ts.segment_type not in ('SYSTEM STATISTICS','TYPE2 UNDO','ROLLBACK')
)
,top_seg as (
   select *
   from (
      select v.*
            ,dense_rank()over(order by sum_by_tab desc) rnk
      from (
         select seg.*
               ,sum(bytes)over(partition by tab_name) sum_by_tab
         from seg   
      ) v
   )
   where rnk<=&N
)
select
   tab_name
  ,sum_by_tab/1024/1024 MBytes_tab
  ,owner
  ,segment_type
  ,segment_name
  ,bytes/1024/1024 MBytes
from top_seg ts
order by rnk,mbytes desc
/
col tab_name      clear;
col owner         clear;
col segment_type  clear;
col segment_name  clear;
col MBytes        clear;
col MBytes_tab    clear;
clear break;
