@inc/input_vars_init;
col sample_time format a24  ;
col username    format a25  ;
col blocker     format 99999;
col text        format a60  ;
col event       format a35  ;
col wait_class  format a25  ;
col ple         format 9999999;
col plo         format 9999999;
col curobj      format a30  ;
col program     format a15  ;
col module      format a15  ;
col action      format a25  ;
col sql_id      format a13  ;
col top_sql     format a13  ;
col p1text      format a20  ;
col p2text      format a20  ;
col p3text      format a20  ;

select
                             h.SAMPLE_TIME
                            ,h.session_id
                            ,h.session_serial#       as serial
                            ,h.blocking_session
                            ,h.user_id
                            ,h.sql_id
&&_IF_ORA112_OR_HIGHER      ,h.sql_exec_id
&&_IF_ORA112_OR_HIGHER      ,h.TOP_LEVEL_SQL_ID      as top_sql
                            ,count(*) over(partition by h.session_id,h.session_serial#,h.sql_id)       as sqlid_count
&&_IF_ORA112_OR_HIGHER      ,count(*) over(partition by h.sql_exec_id)  as sql_exec_count
                            ,h.plsql_entry_object_id ple
                            ,h.plsql_object_id       plo
                            ,h.wait_class
                            ,h.event
                            ,h.module
                            ,substr(h.program,1,15) program
                            ,h.action
                            ,h.current_obj#
                            ,h.p1,h.p1text
                            ,h.p2,h.p2text
                            ,h.p3,h.p3text
from v$active_session_history h
where
  h.session_id=&1
  and h.sample_time >= systimestamp - interval '&2' second
/

col sample_time clear;
col username    clear;
col blocker     clear;
col text        clear;
col event       clear;
col wait_class  clear;
col ple         clear;
col plo         clear;
col curobj      clear;
col program     clear;
col module      clear;
col action      clear;
col sql_id      clear;
col top_sql     clear;
col p1text      clear;
col p2text      clear;
col p3text      clear;