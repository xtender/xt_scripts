prompt ===========================================================
prompt &_C_REVERSE *** ASH by last N minutes by sid &_C_RESET
prompt * Usage @ash sid N [serial]
prompt ===========================================================

@inc/input_vars_init;

@inc/main_with_params_only;

col min_s_time format a25   ;
col max_s_time format a25   ;
col username   format a25   ;
col blocker    format 99999 ;
col text       format a60   ;
col event      format a25   ;
col wait_class format a25   ;
col ple        format a20   ;
col plo        format a20   ;
col curobj     format a30   ;
col program    format a15   ;
col module     format a15   ;
col action     format a15   ;
col sql_id     format a13   ;
with ash_pre as (
                         select
                             h.SAMPLE_TIME
                            ,h.session_id
                            ,h.session_serial#
                            ,h.blocking_session
                            ,h.user_id
                            ,h.sql_id
                            ,count(*) over(partition by h.session_id,h.session_serial#,h.sql_id)       as sqlid_count
&&_IF_ORA112_OR_HIGHER      ,count(*) over(partition by h.sql_exec_id)  as sql_exec_count
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
&&_IF_ORA112_OR_HIGHER      ,h.TOP_LEVEL_SQL_ID
                            --,h.*
                         from gv$active_session_history h
                         where h.sample_time     > sysdate-&2/24/60
                           and (h.session_id      = decode(translate('&1','x0132456789','x'),null,to_number('&1'))
                                or 
                                h.user_id in (select/*+ precompute_subquery */ u.user_id 
                                              from dba_users u 
                                              where lower(u.username) like decode(translate('&1','x0132456789','x'),null,null,lower('%&1%'))
                                             )
                                )
                           and ('&3' is null or h.session_serial# = to_number('&3'))
)
select
                            min(h.SAMPLE_TIME) min_s_time
                           ,max(h.SAMPLE_TIME) max_s_time
                           ,h.blocking_session blocker
                           ,h.user_id
                           ,h.session_id
                           ,h.session_serial#
                           ,(select username from dba_users u where u.user_id=h.user_id) username
                           ,h.sql_id
                           ,sum(sum(sqlid_count)) over(partition by h.sql_id) as sqlid_count
&&_IF_ORA112_OR_HIGHER     ,max(sql_exec_count) as max_sql_exec_count
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
&&_IF_ORA112_OR_HIGHER     ,h.TOP_LEVEL_SQL_ID
from ash_pre h
group by 
    h.blocking_session
   ,h.user_id
   ,h.session_id
   ,h.session_serial#
   ,h.sql_id
   ,h.ple
   ,h.plo
   ,h.event
   ,h.wait_class
   ,h.current_obj#
   ,h.module
   ,h.program
   ,h.action
&&_IF_ORA112_OR_HIGHER   ,h.TOP_LEVEL_SQL_ID
order by sqlid_count desc
&&_IF_ORA112_OR_HIGHER      ,max_sql_exec_count desc
/
col text       clear;
col event      clear;
col wait_class clear;
col ple        clear;
col plo        clear;
col curobj     clear;
col program    clear;
col module     clear;
col action     clear;
col min_s_time clear;
col max_s_time clear;
col username   clear;
/* end main */
@inc/input_vars_undef;