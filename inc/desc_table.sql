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
