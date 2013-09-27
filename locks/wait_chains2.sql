rem *********************************************************** 
rem
rem	File: wait_chains.sql 
prompt	Description: Lock tree built up from V$wait_chains
rem   
rem	From 'Oracle Performance Survival Guide' by Guy Harrison
rem		Chapter 15 Page 478
rem		ISBN: 978-0137011957
rem		See www.guyharrison.net for further information
rem  
rem		This work is in the public domain NSA 
rem   
rem
rem ********************************************************* 


column session_detail   format a45 heading "Sid and module"
column blocker_sid      format 99999 heading "Blkd|by"
column wait_event_text  format a35 heading "Wait event" 
column object_name      format a20 heading "Object"
column sql_text         format a70 heading "current sql"

SELECT RPAD('+', LEVEL ,'-') || sid||' '||sess.module session_detail,
       blocker_sid,  wait_event_text,
       object_name,RPAD(' ', LEVEL )||substr(sql_text,1,60) sql_text
FROM   
        v$wait_chains c
        LEFT OUTER JOIN dba_objects o
            ON (row_wait_obj# = object_id)
        JOIN v$session sess
            USING (sid)
        LEFT OUTER JOIN v$sql sql
            ON (sql.sql_id = sess.sql_id 
            AND sql.child_number = sess.sql_child_number)
CONNECT BY     PRIOR sid = blocker_sid
           AND PRIOR sess_serial# = blocker_sess_serial#
           AND PRIOR INSTANCE = blocker_instance
START WITH blocker_is_valid = 'FALSE'; 

/* Formatted on 4/03/2009 7:26:34 PM (QP5 v5.120.811.25008) */
column session_detail   clear;
column blocker_sid      clear;
column wait_event_text  clear;
column object_name      clear;
column sql_text         clear;