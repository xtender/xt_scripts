@inc/input_vars_init;
col show_text new_val _stext noprint;
select case 
          when ('&1' like 'text') then '  '
          else '--'
       end show_text
from dual;

col sql_id   format a13
col sql_text format a120
col ple      format a40
col plo      format a40
col module   format a12
col program  format a20
col username format a25
with rtsm as (
            select 
               r.sid
              ,r.sql_id
              ,r.sql_exec_id
              ,r.sql_plan_hash_value        as plan_hv
              ,r.user#
              ,r.username
              ,r.module
--              ,r.program
              ,(select p.OBJECT_TYPE||' '|| p.owner||'.'||p.object_name||'.'||p.procedure_name 
                from dba_procedures p 
                where p.object_id=r.plsql_entry_object_id 
                  and p.subprogram_id=r.plsql_entry_subprogram_id
               ) ple
              ,(select p.OBJECT_TYPE||' '|| p.owner||'.'||p.object_name||'.'||p.procedure_name 
                from dba_procedures p 
                where p.object_id=r.plsql_object_id
                  and p.subprogram_id=r.plsql_subprogram_id
               ) plo
              ,r.sql_exec_start
              ,r.ELAPSED_TIME/1e6           as ela_exe
              ,r.CPU_TIME/1e6               as cpu_exe
              ,r.APPLICATION_WAIT_TIME/1e6  as app_exe
              ,r.CONCURRENCY_WAIT_TIME/1e6  as cc_exe
              ,r.USER_IO_WAIT_TIME/1e6      as io_exe
              ,r.PLSQL_EXEC_TIME/1e6        as plsql_exe
              ,r.fetches
              ,r.buffer_gets
              ,r.DISK_READS
&_stext       ,r.sql_text
&_stext       ,r.is_full_sqltext
            from v$sql_monitor r 
            where r.status = 'EXECUTING'
            and username!='DAEMON'
            order by r.ELAPSED_TIME desc
)
select *
from rtsm
where rownum<=15
/
col sql_text clear
col ple      clear
col plo      clear
col module   clear
