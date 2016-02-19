col COLUMN_EXPRESSION for a60;
select 
       ie.table_owner
      ,ie.table_name
      ,ie.index_owner
      ,ie.index_name
      ,ie.column_expression
      ,ie.column_position
from dba_ind_expressions ie
where index_owner like nvl(upper('&2'),'%') 
  and (index_name like upper('&1') or table_name like upper('&1'))
order by 1,2,3,4
/
col COLUMN_EXPRESSION clear;