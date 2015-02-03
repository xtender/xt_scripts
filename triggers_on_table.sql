col BASE_OBJECT_TYPE  for a15;
col TABLE_OWNER       for a30;
col TABLE_NAME        for a30;
col OWNER             for a30;
col TRIGGER_NAME      for a30;
col TRIGGER_TYPE      for a20;
col TRIGGERING_EVENT  for a50;
col COLUMN_NAME       for a30;
col REFERENCING_NAMES noprint;
col WHEN_CLAUSE       for a20;
col DESCRIPTION       for a39;
col ACTION_TYPE       for a10;
col TRIGGER_BODY      noprint;

select 
  tr.BASE_OBJECT_TYPE
 ,tr.TABLE_OWNER
 ,tr.TABLE_NAME
 ,tr.OWNER
 ,tr.TRIGGER_NAME
 ,tr.TRIGGER_TYPE
 ,tr.TRIGGERING_EVENT
 ,tr.COLUMN_NAME
 ,tr.REFERENCING_NAMES
 ,tr.WHEN_CLAUSE
 ,tr.STATUS
 ,tr.DESCRIPTION
 ,tr.ACTION_TYPE
 ,tr.TRIGGER_BODY
 ,tr.CROSSEDITION
 ,tr.BEFORE_STATEMENT
 ,tr.BEFORE_ROW
 ,tr.AFTER_ROW
 ,tr.AFTER_STATEMENT
 ,tr.INSTEAD_OF_ROW
 ,tr.FIRE_ONCE
 ,tr.APPLY_SERVER_ONLY
from dba_triggers tr 
where 
     tr.table_owner like nvl(upper('&2'),'%')
 and tr.table_name like upper('&1')
order by 1,2,3,4,5
/

col BASE_OBJECT_TYPE  clear;
col TABLE_OWNER       clear;
col TABLE_NAME        clear;
col OWNER             clear;
col TRIGGER_NAME      clear;
col TRIGGER_TYPE      clear;
col TRIGGERING_EVENT  clear;
col COLUMN_NAME       clear;
col REFERENCING_NAMES clear;
col WHEN_CLAUSE       clear;
col DESCRIPTION       clear;
col ACTION_TYPE       clear;
col TRIGGER_BODY      clear;
