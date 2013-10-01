col TABLE_NAME  format a30;
col COLUMN_NAME format a30;
break on TABLE_NAME on INDEX_NUMBER skip 1
select 
    fc.TABLE_NAME
   ,fc.INDEX_NUMBER
   ,fc.COLUMN_POSITION
   ,fc.COLUMN_NAME
from v$indexed_fixed_column fc
where table_name like upper('&1')
order by 1,2,3
/
clear break;
col TABLE_NAME  clear;
col COLUMN_NAME clear;