col elaexe              for 99999.99990;
col cpu_time            for 99999.99990;
col app_wait            for 99999.99990;
col plsql_t             for 99999.99990;
col java_exec_t         for 99999.99990;
col opt_mode            for a12
col P_schema            for a20
col sql_text            for a150;

prompt  2. INSERT;
prompt  3. SELECT;
prompt  6. UPDATE;
prompt  7. DELETE;
prompt 47. PL/SQL EXECUTE;

accept excludelist prompt "Enter command types for exclude: ";
with top_sql_ids as (
         select--+ no_merge
            sql_id
         from
            (
            select a.sql_id,a.elapsed_time
            from v$sqlarea a 
            where a.command_type not in (0&excludelist)
            order by a.elapsed_time desc
            )
         where rownum<=10
)
select
    s.sql_id
   ,s.elapsed_time/1e6                                                 "Elapsed(sec)"
   ,s.executions             
   ,decode(s.executions,0,0, s.ROWS_PROCESSED           /s.executions)  rows_per_exec
   ,decode(s.executions,0,0, s.elapsed_time/1e6/s.executions)           elaexe
   ,decode(s.executions,0,0, s.CPU_TIME/1e6/s.executions)               cpu_time
   ,decode(s.executions,0,0, s.APPLICATION_WAIT_TIME/1e6/s.executions)  app_wait
   ,decode(s.executions,0,0, s.CONCURRENCY_WAIT_TIME/1e6/s.executions)  concurrency
   ,decode(s.executions,0,0, s.USER_IO_WAIT_TIME    /1e6/s.executions)  io_wait
   ,decode(s.executions,0,0, s.PLSQL_EXEC_TIME      /1e6/s.executions)  plsql_t
   ,decode(s.executions,0,0, s.java_exec_time       /1e6/s.executions)  java_exec_t
   ,s.OPTIMIZER_MODE                                                    opt_mode
   ,s.OPTIMIZER_COST                                                    cost
   ,s.OPTIMIZER_ENV_HASH_VALUE                                          env_hash
   ,s.PARSING_SCHEMA_NAME                                               P_schema
   ,substr(s.sql_text,1,150) as sql_text
from top_sql_ids ids
    ,v$sqlarea s
where ids.sql_id=s.sql_id
/
col elaexe       clear;
col cpu_time     clear;
col app_wait     clear;
col plsql_t      clear;
col java_exec_t  clear;
col opt_mode     clear;
col P_schema     clear;
col sql_text     clear;
