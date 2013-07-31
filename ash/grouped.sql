with t as (
      select
         h.SAMPLE_TIME
         ,h.session_id
         ,h.blocking_session
         ,h.user_id
         ,(select username from dba_users u where u.user_id=h.user_id) username
         ,h.sql_id
         ,coalesce(
            (select a.sql_text from v$sqlarea a where a.sql_id=h.sql_id and rownum=1)
            ,(select substr(to_char(a.sql_text),1,4000) from dba_hist_sqltext a where a.sql_id=h.sql_id and rownum=1 and dbid=(select dbid from v$database))
          ) text
         ,pe.owner || '.'||pe.object_name || '.'||pe.PROCEDURE_NAME pe
         ,po.owner || '.'||po.object_name || '.'||po.PROCEDURE_NAME po
         ,h.event
         ,h.p1,h.p1text
         ,h.p2,h.p2text
         ,h.p3,h.p3text
         ,h.wait_class
         ,h.current_obj#
         ,(select object_name from dba_objects o where o.object_id=h.current_obj#) curobj
         ,h.module
         ,h.program
         ,h.action
--         ,h.* 
      from v$active_session_history h
          ,dba_procedures pe
          ,dba_procedures po
      where 
             pe.object_id    (+)  = h.PLSQL_ENTRY_OBJECT_ID
         and pe.SUBPROGRAM_ID(+)  = h.PLSQL_ENTRY_SUBPROGRAM_ID
         and po.object_id    (+)  = h.PLSQL_OBJECT_ID
         and po.SUBPROGRAM_ID(+)  = h.PLSQL_SUBPROGRAM_ID
         /*
         and (
             h.PLSQL_ENTRY_OBJECT_ID in (44399,44400,44412,44426)
          or h.PLSQL_OBJECT_ID in (44399,44400,44412,44426)
            ) --*/
)
select username,pe,po,event,program,module,curobj,action,sql_id,count(*)
from t
group by username,pe,po,event,program,module,curobj,action,sql_id
order by count(*) desc
