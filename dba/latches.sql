select --l.pid
       l.sid
       --,l.laddr
       ,l.NAME
       ,l.GETS
       ,s.sql_id
       ,s.SQL_CHILD_NUMBER||', '||s.SQL_HASH_VALUE "child/hash"
       ,s.EVENT
       ,s.WAIT_TIME
       ,s.SECONDS_IN_WAIT
       ,s.LOCKWAIT
       ,s.STATE

       ,s.ROW_WAIT_OBJ#
         ||': '||(select object_name from dba_objects o where o.OBJECT_ID=s.ROW_WAIT_OBJ#) Row_wait_obj
       --,s.ROW_WAIT_FILE#
       ,s.ROW_WAIT_BLOCK#
       ,s.ROW_WAIT_ROW#

       ,s.PLSQL_OBJECT_ID
         ||': '||(select o.owner||'.'||o.object_name from dba_objects o where o.OBJECT_ID=s.PLSQL_OBJECT_ID) PLSQL_Object
       ,s.PLSQL_ENTRY_OBJECT_ID
         ||': '||(select o.owner||'.'||o.object_name from dba_objects o where o.OBJECT_ID=s.PLSQL_ENTRY_OBJECT_ID) PLSQL_ENTRY
       ,s.PLSQL_SUBPROGRAM_ID
       ,s.USERNAME
       ,s.PROGRAM
       ,s.ACTION
from v$latchholder l
    ,v$session s
where l.sid=s.sid
