@inc/input_vars_init
col sid             format 999999
col status          format a30
col m_elaexe        format a15 heading "Elapsed(MIN:SS)"
col username        format a25
col program         format a20
col PLE             format a35
col PLO             format a35
col ERROR_NUMBER    format a20
col error_message   format a40
col a1 format a5 head"";
col a2 format a6 head "";

with v as (
select 
     STATUS
   , SID
   , SESSION_SERIAL#                                as serial#
   , SQL_PLAN_HASH_VALUE                            as plan_hv
   , SQL_EXEC_ID
   , SQL_EXEC_START

   , to_char(trunc(ELAPSED_TIME/1e6/60))
     ||':'||
     to_char(mod(ELAPSED_TIME,60e6)/1e6,'fm00.000')  as m_elaexe
   , USERNAME
   , PROGRAM

   , ELAPSED_TIME               as ELA_TIME
   , CPU_TIME
   , FETCHES
   , (select pm.output_rows from gv$sql_plan_monitor pm where pm.sql_id=m.sql_id and pm.SQL_EXEC_ID=m.SQL_EXEC_ID and pm.inst_id=m.inst_id and pm.key=m.key and pm.PLAN_LINE_ID=0) "ROWS"

   , BUFFER_GETS                as BUF_GETS
   , DISK_READS                 as DISK_READS
   , DIRECT_WRITES              as DIRECT_WRITES
   , APPLICATION_WAIT_TIME      as APP_WT
   , CONCURRENCY_WAIT_TIME      as CONCUR_WT
   , CLUSTER_WAIT_TIME          as CLUST_WT
   , USER_IO_WAIT_TIME          as IO_WT
   , PLSQL_EXEC_TIME            as PLSQL_WT
   , JAVA_EXEC_TIME             as JAVA_WT

   , ERROR_NUMBER
   , ERROR_FACILITY
   , ERROR_MESSAGE
--   , BINDS_XML
--   , OTHER_XML

   , PHYSICAL_READ_REQUESTS
   , PHYSICAL_READ_BYTES
   , PHYSICAL_WRITE_REQUESTS
   , PHYSICAL_WRITE_BYTES

--   , PLSQL_ENTRY_OBJECT_ID      as PLE_OBJ
--   , PLSQL_ENTRY_SUBPROGRAM_ID  as PLE_SUB
   , (select p.owner||'.'||p.object_name||'.'||p.procedure_name from dba_procedures p where p.object_id=PLSQL_ENTRY_OBJECT_ID and p.subprogram_id=PLSQL_ENTRY_SUBPROGRAM_ID) PLE
--   , PLSQL_OBJECT_ID            as PL_OBJ
--   , PLSQL_SUBPROGRAM_ID        as PL_SUB
   , (select p.owner||'.'||p.object_name||'.'||p.procedure_name from dba_procedures p where p.object_id=PLSQL_OBJECT_ID and p.subprogram_id=PLSQL_SUBPROGRAM_ID) PLO

from gv$sql_monitor m
where 
  m.sql_id like '&1'
  &2 
  &3
  &4
  &5
  &6
order by SQL_EXEC_START desc
)
select *
from v
where rownum<=20;

col status          clear;
col m_elaexe        clear;
col username        clear;
col program         clear;
col ERROR_NUMBER    clear;
col error_message   clear;
@inc/input_vars_undef;