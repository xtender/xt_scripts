define tab_owner = "&1"
define tab_name = "&2"

col segment_size format a14 heading "Seg.Size(MB)"

select 
  t.owner
 ,t.table_name
 ,t.tablespace_name
 ,t.logging
 ,t.num_rows
 ,t.empty_blocks
 ,t.LAST_ANALYZED
 ,t.BUFFER_POOL
 ,(select to_char(sum(bytes)/1024.0/1024.0,'999g999g990d9',q'[NLS_NUMERIC_CHARACTERS = '. ']') 
    from dba_segments s 
    where s.owner=t.owner
      and s.segment_name=t.table_name
  ) as segment_size
from dba_tables t
where t.table_name = upper('&tab_name')
  and t.owner like upper('&tab_owner')
/
col tab_name format a20
col n format 99
col ind_name format a30
col tblspace format a10
col columns format a50
col blevel format 99
--col ind_owner format a10
break on tab_name

select--+ LEADING(@"SEL$18" "F"@"SEL$18" "S"@"SEL$18" "U"@"SEL$18" "TS"@"SEL$18")
   i.table_owner||'.'||i.table_name as tab_name
  ,row_number()over(partition by i.table_owner||'.'||i.table_name order by i.index_name) as n
  ,i.owner --as ind_owner
   ||'.'||i.index_name  as ind_name
  ,i.tablespace_name tblspace
  ,i.blevel
  ,i.num_rows
  ,i.leaf_blocks as leafs
  ,i.distinct_keys as ndv
  ,i.partitioned
  ,to_char(i.last_analyzed,'yyyy-mm-dd') analyzed
  ,(select
    listagg( ic.column_name||decode(ic.descend,'ASC',null,' '||ic.descend)
           ,','
     ) within group(order by ic.column_position)
    from dba_ind_columns ic
    where i.owner=ic.INDEX_OWNER and i.index_name=ic.INDEX_NAME 
   ) as columns
  ,(select to_char(sum(bytes)/1024.0/1024.0,'999g999g990d9',q'[NLS_NUMERIC_CHARACTERS = '. ']') 
    from dba_segments s 
    where s.owner=i.OWNER
      and s.segment_name=i.INDEX_NAME
   ) as segment_size
from
     dba_indexes i
where i.table_name=upper('&tab_name')
  and i.table_owner like upper('&tab_owner')
/
col tab_name  clear
col n         clear
col ind_name  clear
col columns   clear
col segment_size clear
--col ind_owner clear
clear break
