--set echo off
ttitle center "Дерево блокировок" skip 2;
column level format 99
column sid format a15
column serial format a4
column username format a20
column osuser format a10
column wait_class format a32
column EVENT format a20
column wtime format 999
column entry format a20
column pl_oid format a20

select
       --level n,
	   lpad(sid,level*3,'.') sid
      ,to_char(serial#) serial
      ,username||'('||s.osuser||')' username
--      ,blocking_session
--      ,terminal
      ,s.wait_class||': '||s.EVENT wait_class
      ,s.WAIT_TIME+s.SECONDS_IN_WAIT wtime
      ,sql_id
--      ,(select substr(v$sql.sql_text,1,30) from v$sql where v$sql.sql_id=s.sql_id and rownum=1) sqlsubstring
--      ,(select v$sql.sql_fulltext from v$sql where v$sql.sql_id=s.sql_id and rownum=1) sqltext
      ,(select o.object_name from dba_objects o where o.OBJECT_ID=s.PLSQL_ENTRY_OBJECT_ID) entry
      ,(select o.object_name from dba_objects o where o.OBJECT_ID=s.PLSQL_OBJECT_ID) pl_oid
from   v$session s
start with blocking_session is null
           and sid IN (select/*+ precompute_subquery */ 
                             blocking_session
                       from   v$session
                       where  blocking_session_status = 'VALID')
connect by prior s.sid=s.BLOCKING_SESSION 
                 and blocking_session_status = 'VALID'
/
ttitle off
--set echo on