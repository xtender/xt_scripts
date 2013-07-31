col user_name     format a25
col sql_text      format a60;
col cursor_type   format a35;

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
from gv$open_cursor c 
where sid=&1
order by SQL_EXEC_ID, CURSOR_TYPE, USER_NAME
/
col user_name     clear;
col sql_text      clear;
col cursor_type   clear;
