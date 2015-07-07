set lines 80
describe &2..&1

set lines 1000;
col owner           for a30;
col table_name      for a30;
col column_name     for a30;
col comments        for a80;
select c.owner,c.table_name,c.column_name,c.comments
from dba_col_comments c
where 
     c.owner='&2' 
 and c.table_name='&1';

col partitioning_type for a17;
col subpartition_type for a17;
select 
   pt.partitioning_type
  ,pt.partition_count
  ,pt.subpartition_type
  ,pc.column_position      key#
  ,pc.column_name
from dba_part_tables pt
    ,dba_part_key_columns pc
where pt.owner='&2' 
  and pt.table_name='&1'
  and pc.owner = pt.owner
  and pc.name = pt.table_name
order by 1,2,3,4
/
col partitioning_type clear;
col subpartition_type clear;