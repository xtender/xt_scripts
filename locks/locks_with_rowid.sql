set echo off
ttitle center 'Блокировки с rowid' skip 2
select s.ROW_WAIT_OBJ# b_obj
       ,o.OBJECT_NAME
       ,s.BLOCKING_SESSION_STATUS b_status
       ,s.BLOCKING_SESSION b_sid
       ,dbms_rowid.rowid_create(1,ROW_WAIT_OBJ#,ROW_WAIT_FILE#,ROW_WAIT_BLOCK#,ROW_WAIT_ROW#) srowid
       ,s.USERNAME,s.OSUSER
       ,s.module
       ,s.sid,s.SERIAL#
       ,(select a.code||':'||a.label
         from balance b,account a 
         where  ROW_WAIT_OBJ# = 13178
          and b.account=a.classified 
          and b.rowid=dbms_rowid.rowid_create(1,ROW_WAIT_OBJ#,ROW_WAIT_FILE#,ROW_WAIT_BLOCK#,ROW_WAIT_ROW#)
        ) account
        --*/
       --,s.*
from v$session s 
     ,dba_objects o
where
s.BLOCKING_SESSION_STATUS='VALID'
and o.OBJECT_ID=s.ROW_WAIT_OBJ#
