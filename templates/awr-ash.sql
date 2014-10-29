with snaps as (
      select sn.dbid,sn.snap_id,sn.instance_number
      from dba_hist_snapshot sn
      where sn.end_interval_time   >= timestamp'&time_start'+0 
        and sn.begin_interval_time <= timestamp'&time_end'+0
      and sn.dbid = (select db.dbid from v$database db)
      order by 1,2,3
)
select
       SAMPLE_TIME
      ,SESSION_ID
      ,SESSION_SERIAL#
      ,SESSION_TYPE
      ,FLAGS
      ,USER_ID
      ,(select username from dba_users u where u.user_id = h.user_id) username
      ,TOP_LEVEL_SQL_ID
      ,(select sql_text from dba_hist_sqltext t where t.sql_id= h.TOP_LEVEL_SQL_ID and t.dbid=h.dbid) top_sql_text
      ,SQL_ID
      ,IS_SQLID_CURRENT
      ,(select sql_text from dba_hist_sqltext t where t.sql_id= h.sql_id and t.dbid=h.dbid) sql_text
      ,SQL_CHILD_NUMBER
      ,SQL_OPCODE
      ,SQL_OPNAME
      ,FORCE_MATCHING_SIGNATURE
      ,TOP_LEVEL_SQL_OPCODE
      ,SQL_PLAN_HASH_VALUE
      ,SQL_PLAN_LINE_ID
      ,SQL_PLAN_OPERATION
      ,SQL_PLAN_OPTIONS
      ,SQL_EXEC_ID
      ,SQL_EXEC_START
      ,PLSQL_ENTRY_OBJECT_ID
      ,PLSQL_ENTRY_SUBPROGRAM_ID
      ,PLSQL_OBJECT_ID
      ,PLSQL_SUBPROGRAM_ID
      ,QC_INSTANCE_ID
      ,QC_SESSION_ID
      ,QC_SESSION_SERIAL#
      ,PX_FLAGS
      ,EVENT
      ,EVENT_ID
      ,SEQ#
      ,P1TEXT
      ,P1
      ,P2TEXT
      ,P2
      ,P3TEXT
      ,P3
      ,WAIT_CLASS
      ,WAIT_CLASS_ID
      ,WAIT_TIME
      ,SESSION_STATE
      ,TIME_WAITED
      ,BLOCKING_SESSION_STATUS
      ,BLOCKING_SESSION
      ,BLOCKING_SESSION_SERIAL#
      ,BLOCKING_INST_ID
      ,BLOCKING_HANGCHAIN_INFO
      ,CURRENT_OBJ#
      ,CURRENT_FILE#
      ,CURRENT_BLOCK#
      ,CURRENT_ROW#
      ,TOP_LEVEL_CALL#
      ,TOP_LEVEL_CALL_NAME
      ,CONSUMER_GROUP_ID
      ,XID
      ,REMOTE_INSTANCE#
      ,TIME_MODEL
      ,IN_CONNECTION_MGMT
      ,IN_PARSE
      ,IN_HARD_PARSE
      ,IN_SQL_EXECUTION
      ,IN_PLSQL_EXECUTION
      ,IN_PLSQL_RPC
      ,IN_PLSQL_COMPILATION
      ,IN_JAVA_EXECUTION
      ,IN_BIND
      ,IN_CURSOR_CLOSE
      ,IN_SEQUENCE_LOAD
      ,CAPTURE_OVERHEAD
      ,REPLAY_OVERHEAD
      ,IS_CAPTURED
      ,IS_REPLAYED
      ,SERVICE_HASH
      ,PROGRAM
      ,MODULE
      ,ACTION
      ,CLIENT_ID
      ,MACHINE
      ,PORT
      ,ECID
      ,DBREPLAY_FILE_ID
      ,DBREPLAY_CALL_COUNTER
      ,TM_DELTA_TIME
      ,TM_DELTA_CPU_TIME
      ,TM_DELTA_DB_TIME
      ,DELTA_TIME
      ,DELTA_READ_IO_REQUESTS
      ,DELTA_WRITE_IO_REQUESTS
      ,DELTA_READ_IO_BYTES
      ,DELTA_WRITE_IO_BYTES
      ,DELTA_INTERCONNECT_IO_BYTES
      ,PGA_ALLOCATED
      ,TEMP_SPACE_ALLOCATED
from snaps 
    ,dba_hist_active_sess_history h
where 
     snaps.dbid=h.dbid
 and snaps.snap_id = h.snap_id
 and snaps.instance_number = h.instance_number
and h.user_id in (select/*+ precompute_subquery */ u.user_id from dba_users u where u.username='&username')
-- and h.sql_id          = '...'
-- and h.session_id      = ...
-- and h.session_serial# = ...
-- and session_id       != 209
order by snaps.dbid,snaps.snap_id,snaps.instance_number
/
