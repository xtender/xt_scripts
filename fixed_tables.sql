col table_name  for a30;
col column_name for a30;
col type_name   for a30;
select 
       t.table_num
     , t.OBJECT_ID
     , t.name       as  table_name
     , c.KQFCOCNO   as position
     , c.KQFCONAM   as column_name
     , c.KQFCODTY
     , (select o$.name from sys.type$ t$,sys.obj$ o$ where o$.oid$ = t$.tvoid and t$.typecode = c.KQFCODTY) type_name
     , c.KQFCOTYP
     , c.KQFCOSIZ column_size
from v$fixed_table t
    ,x$kqfco c
where t.OBJECT_ID = c.KQFCOTOB
  and t.name like upper('&1')
/
col table_name  clear;
col column_name clear;
col type_name   clear;