col min_s_time format a25   ;
col max_s_time format a25   ;
col username   format a25   ;
col blocker    format 99999 ;
col text       format a60  ;
col ple        format a20   ;
col plo        format a20   ;
col curobj     format a30   ;
col program    format a15   ;
col action     format a15   ;
col sql_id     format a13   ;
with ash_pre as (
         select
             h.SAMPLE_TIME
            ,h.session_id
            ,h.blocking_session
            ,h.user_id
            ,h.sql_id
            ,h.plsql_entry_object_id ple
            ,h.plsql_object_id       plo
            ,h.event
            ,h.p1,h.p1text
            ,h.p2,h.p2text
            ,h.p3,h.p3text
            ,h.wait_class
            ,h.current_obj#
            ,h.module
            ,substr(h.program,1,15) program
            ,h.action
            --,h.*
         from gv$active_session_history h
         where h.SAMPLE_TIME >sysdate-&2/24/60
         and session_id=&1
)
select
    min(h.SAMPLE_TIME) min_s_time
   ,max(h.SAMPLE_TIME) max_s_time
   ,h.blocking_session blocker
   ,h.user_id
   ,(select username from dba_users u where u.user_id=h.user_id) username
   ,h.sql_id
   ,substr(
       coalesce(
         (select a.sql_text from v$sqlarea a where a.sql_id=h.sql_id and rownum=1)
         ,(select substr(to_char(a.sql_text),1,4000) from dba_hist_sqltext a where a.sql_id=h.sql_id and rownum=1 and dbid=(select dbid from v$database))
       ) 
      ,1,100)
       as text
   ,(select object_name from dba_objects o where o.object_id=h.ple) ple
   ,(select object_name from dba_objects o where o.object_id=h.plo) plo
   ,h.event
   ,h.wait_class
   ,h.current_obj#
   ,(select object_name from dba_objects o where o.object_id=h.current_obj#) curobj
   ,h.module
   ,h.program
   ,h.action
from ash_pre h
group by 
    h.blocking_session
   ,h.user_id
   ,h.sql_id
   ,h.ple
   ,h.plo
   ,h.event
   ,h.wait_class
   ,h.current_obj#
   ,h.module
   ,h.program
   ,h.action
order by 1,2 
/
col text       clear;
col ple        clear;
col plo        clear;
col curobj     clear;
col program    clear;
col action     clear;
col min_s_time clear;
col max_s_time clear;
col username   clear;
