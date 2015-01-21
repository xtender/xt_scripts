@inc/params_init;
REM ############### COMMON FORMATTING #######################
col SQL_ID                              for a13
col sql_child_number    head CH#        for 999
col SQL_PROFILE         head Profile/Baseline/Patch   for a30;
col end_of_fetch_count  head "EO_FTCHS"
REM ############### LOCAL FORMATTING #######################
col elaexe              for 99999.99990
col first_load_time     for a20
col opt_mode            for a12
col P_schema            for a20
col proc_name           for a30

with sqlids as (
   select distinct sql_id 
   from (
       select '&1'  sql_id from dual union all
       select '&2'  sql_id from dual union all
       select '&3'  sql_id from dual union all
       select '&4'  sql_id from dual union all
       select '&5'  sql_id from dual union all
       select '&6'  sql_id from dual union all
       select '&7'  sql_id from dual union all
       select '&8'  sql_id from dual union all
       select '&9'  sql_id from dual union all
       select '&10' sql_id from dual
    )
   where sql_id is not null
)
select 
    s.inst_id                                                           inst
   ,s.sql_id                                                            sql_id
   ,s.CHILD_NUMBER                                                      sql_child_number
   ,s.address                                                           parent_handle
   ,s.child_address                                                     object_handle
   ,s.PLAN_HASH_VALUE                                                   plan_hv
   ,s.hash_value                                                        hv
   ,s.SQL_PROFILE                                           
&_IF_ORA11_OR_HIGHER ||' / '||s.sql_plan_baseline
&_IF_ORA11_OR_HIGHER ||' / '||s.sql_patch
        as sql_profile
   ,decode(s.EXECUTIONS,0,0, s.ELAPSED_TIME/1e6/s.EXECUTIONS)           elaexe
   ,s.EXECUTIONS                                                        cnt
   ,s.FETCHES                                                           fetches
   ,s.END_OF_FETCH_COUNT                                                end_of_fetch_count
   ,s.FIRST_LOAD_TIME                                                   first_load_time
   ,s.PARSE_CALLS                                                       parse_calls
   ,decode(s.executions,0,0, s.DISK_READS    /s.executions)             disk_reads
   ,decode(s.executions,0,0, s.BUFFER_GETS   /s.executions)             buffer_gets
   ,decode(s.executions,0,0, s.DIRECT_WRITES /s.executions)             direct_writes
   ,decode(s.executions,0,0, s.CPU_TIME             /1e6/s.executions)  cpu_time
   ,decode(s.executions,0,0, s.USER_IO_WAIT_TIME    /1e6/s.executions)  io_wait
   ,decode(s.executions,0,0, s.APPLICATION_WAIT_TIME/1e6/s.executions)  app_wait
   ,decode(s.executions,0,0, s.CONCURRENCY_WAIT_TIME/1e6/s.executions)  concurrency
   ,decode(s.executions,0,0, s.PLSQL_EXEC_TIME      /1e6/s.executions)  plsql_t
   ,decode(s.executions,0,0, s.java_exec_time       /1e6/s.executions)  java_exec_t
   ,decode(s.executions,0,0, s.ROWS_PROCESSED           /s.executions)  rows_per_exec
   ,s.OPTIMIZER_MODE                                                    opt_mode
   ,s.OPTIMIZER_COST                                                    cost
   ,s.OPTIMIZER_ENV_HASH_VALUE                                          env_hash
   ,s.PARSING_SCHEMA_NAME                                               P_schema
   ,s.PROGRAM_ID
   ,(select object_name from dba_objects o where o.object_id=s.PROGRAM_ID) proc_name
   ,s.PROGRAM_LINE#                                                        proc_line
from sqlids,gv$sql s 
where 
    sqlids.sql_id = s.sql_id
order by
    inst,
    sql_id,
    hash_value,
    child_number
/
col first_load_time clear
col opt_mode        clear
col P_schema        clear
col proc_name       clear

@inc/params_undef;