break on owner on index_name on index_type on uniqueness on table_name on blevel on leaf_blocks on num_rows on last_analyzed
col owner       format a20
col index_name  format a30
col index_type  format a20
col uniqueness  format a9
col table_name  format a30
col column_name format a30
select i.owner
      ,i.index_name
      ,i.index_type
      ,i.uniqueness
      ,i.table_name
      ,i.blevel
      ,i.leaf_blocks
      ,i.num_rows
      ,i.last_analyzed
      ,ic.COLUMN_POSITION
      ,ic.COLUMN_NAME
from dba_indexes i
    ,dba_ind_columns ic
where
    i.index_name='&1'
and i.owner     ='&2'
and i.index_name=ic.index_name
and i.owner=ic.INDEX_OWNER
order by i.owner,i.index_name,ic.COLUMN_POSITION;
col owner       clear
col index_name  clear
col index_type  clear
col uniqueness  clear
col table_name  clear
col COLUMN_NAME clear