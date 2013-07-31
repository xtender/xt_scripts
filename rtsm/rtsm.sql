define sm_count = "&1";

col sm_count           noprint new_value sm_count
select 
  case 
     when regexp_like(trim('&sm_count'),'^\d+$') 
        then to_number(regexp_substr('&sm_count','\d+'))
     else 5
  end sm_count
from dual;

col sm_count clear;
-- formatting:
col sql_text format a70;

REM main query;
with long_sql as (
      select
         sm.sid
        ,sm.SESSION_SERIAL#            as "SERIAL#"
        ,sm.sql_id
        ,sm.sql_text
        ,sm.is_full_sqltext            as "FULL"
        ,sm.SQL_EXEC_START
        --,sm.SQL_EXEC_ID
        ,sm.SQL_PLAN_HASH_VALUE        as "PLAN_HV"
         --,sm.key
        ,sm.status
        --,sm.user#
        ,sm.username
        ,sm.module
        ,sm.action
        ,sm.ELAPSED_TIME
        --,sm.QUEUING_TIME
        ,sm.CPU_TIME
        ,sm.USER_IO_WAIT_TIME
        ,sm.PLSQL_EXEC_TIME
        ,sm.APPLICATION_WAIT_TIME
        ,sm.CONCURRENCY_WAIT_TIME
        ,sm.CLUSTER_WAIT_TIME
        ,sm.JAVA_EXEC_TIME
        ,sm.fetches
        ,sm.buffer_gets
        ,sm.disk_reads
        ,sm.direct_writes
        ,sm.IO_INTERCONNECT_BYTES
        ,sm.PHYSICAL_READ_REQUESTS
        ,sm.PHYSICAL_WRITE_REQUESTS
        ,sm.PHYSICAL_WRITE_BYTES
      		  
        --,sm.service_name
        --,sm.CLIENT_IDENTIFIER
        --,sm.CLIENT_INFO
        ,sm.program
        ,sm.PLSQL_ENTRY_OBJECT_ID
        ,sm.PLSQL_ENTRY_SUBPROGRAM_ID
        ,sm.PLSQL_OBJECT_ID
        ,sm.PLSQL_SUBPROGRAM_ID
        ,sm.FIRST_REFRESH_TIME
        ,sm.LAST_REFRESH_TIME
        ,sm.REFRESH_COUNT
        --,sm.FORCE_MATCHING_SIGNATURE
        --,sm.SQL_CHILD_ADDRESS
        /* -- parallels:
        ,sm.PX_IS_CROSS_INSTANCE
        ,sm.PX_MAXDOP
        ,sm.PX_MAXDOP_INSTANCES
        ,sm.PX_SERVERS_REQUESTED
        ,sm.PX_SERVERS_ALLOCATED
        ,sm.PX_SERVER#
        ,sm.PX_SERVER_GROUP
        ,sm.PX_SERVER_SET
        ,sm.PX_QCINST_ID
        ,sm.PX_QCSID
        --*/
        ,sm.ERROR_NUMBER
        ,sm.ERROR_FACILITY
        ,sm.ERROR_MESSAGE
        ,sm.BINDS_XML
        ,sm.OTHER_XML
      from v$sql_monitor sm
      where 
        sm.status not in ('DONE','DONE (ALL ROWS)')
        and sm.username not in ('DAEMON','NAQ')
      order by sql_exec_start
)
select *
from long_sql ls
where rownum<=&sm_count;

col sql_text clear;
