col serial           format 999999;
col sample_time      format a23;
col username         format a25;
col top_level_sql_id format a13;
col action           format a30;
col event            format a30;
col wait_class       format a30;
col curobj           format a30;
col module           format a30;
col program          format a15;
with ash_pre as (
         select
             h.inst_id
            ,h.SAMPLE_TIME
            ,h.sample_id
            ,h.session_id            as sid
            ,h.session_serial#       as serial
            ,h.blocking_session
            ,h.user_id
            ,h.sql_id
&_IF_ORA112_OR_HIGHER            ,h.top_level_sql_id
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
         where h.SAMPLE_TIME > systimestamp- interval '30' minute
)
select * 
from 
(
   select h.inst_id
         ,h.sample_time
         ,h.sid
         ,h.serial
         ,h.user_id
         ,(select username from dba_users u where u.user_id=h.user_id) username
         ,h.sql_id
&_IF_ORA112_OR_HIGHER         ,h.top_level_sql_id
         ,h.module
         ,h.program
         ,h.action
         ,h.event
         ,h.wait_class
         ,h.current_obj#
         ,(select object_name from dba_objects o where o.object_id=h.current_obj#) curobj
         ,(select object_name from dba_objects o where o.object_id=h.ple) ple
         ,(select object_name from dba_objects o where o.object_id=h.plo) plo
   from ash_pre h
   where h.sql_id='&1' 
&_IF_ORA112_OR_HIGHER       or h.top_level_sql_id='&1'
   order by sample_id desc
)
where rownum<=20
/
col serial           clear;
col sample_time      clear;
col username         clear;
col top_level_sql_id clear;
col action           clear;
col event            clear;
col wait_class       clear;
col curobj           clear;
col module           clear;
col program          clear;
