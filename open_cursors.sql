col user_name     format a25
col sql_text      format a60;
col cursor_type   format a35;
col proc_name     format a50;

select 
    c.INST_ID
   --,c.SADDR
   ,c.SID
   ,c.USER_NAME
   --,c.ADDRESS
   --,c.HASH_VALUE
   ,c.SQL_ID
   ,c.LAST_SQL_ACTIVE_TIME
   ,c.SQL_EXEC_ID
   ,c.CURSOR_TYPE 
   ,c.SQL_TEXT
   ,(select nvl2(o.owner, o.owner||'.'||object_name,'...') from dba_objects o where o.object_id=s.PROGRAM_ID) proc_name
   ,s.PROGRAM_LINE#                                                        proc_line
from gv$open_cursor c 
    ,gv$sqlarea s
where c.sid=&1
  and c.INST_ID = s.INST_ID(+)
  and c.SQL_ID  = s.SQL_ID(+)
order by SQL_EXEC_ID, CURSOR_TYPE, USER_NAME
/
col user_name     clear;
col sql_text      clear;
col cursor_type   clear;
col proc_name     clear;