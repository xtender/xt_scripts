@inc/input_vars_init;
prompt &_C_RED* Show top N cursor by child count... &_C_RESET;
prompt *** Usage: @sql_shared_top N [+reason]

col if_reason new_val _if_reason noprint;
select case when lower('&2') like '+reason' then '' else '--' end if_reason from dual;
col if_reason clear;

col CHILD_NUMBER            format 99999;
col sql_type_mismatch       format a8 heading sql_type_mismatch      ;
col OPTIMIZER_MISMATCH      format a9 heading OPTIMIZER_MISMATCH     ;
col OUTLINE_MISMATCH        format a7 heading OUTLINE_MISMATCH       ;
col STATS_ROW_MISMATCH      format a9 heading STATS_ROW_MISMATCH     ;
col LITERAL_MISMATCH        format a7 heading LITERAL_MISMATCH       ;
col BIND_MISMATCH           format a4 heading BIND_MISMATCH          ;
col REMOTE_TRANS_MISMATCH   format a6 heading REMOTE_TRANS_MISMATCH  ;
col USER_BIND_PEEK_MISMATCH format a9 heading USER_BIND_PEEK_MISMATCH;
col OPTIMIZER_MODE_MISMATCH format a9 heading OPTIMIZER_MODE_MISMATCH;
col USE_FEEDBACK_STATS      format a8 heading FEEDBACK               ;
col reason                  format a70 heading reason                ;
col reason_xml              format a70 heading reason                ;

with t as (
   select t1.*
         ,dense_rank() over(order by cnt desc) rn
   from (
      select
          c.*
         ,count(*) over(partition by c.sql_id) cnt
      from v$sql_shared_cursor c
   ) t1
   where cnt>0
)
select
      SQL_ID
     ,cnt
     ,CHILD_NUMBER           
     ,ltrim(
           decode(c.UNBOUND_CURSOR                ,'Y',',UNBOUND_CURSOR')
         ||decode(c.SQL_TYPE_MISMATCH             ,'Y',',SQL_TYPE_MISMATCH')
         ||decode(c.OPTIMIZER_MISMATCH            ,'Y',',OPTIMIZER_MISMATCH')
         ||decode(c.OUTLINE_MISMATCH              ,'Y',',OUTLINE_MISMATCH')
         ||decode(c.STATS_ROW_MISMATCH            ,'Y',',STATS_ROW_MISMATCH')
         ||decode(c.LITERAL_MISMATCH              ,'Y',',LITERAL_MISMATCH')
         ||decode(c.FORCE_HARD_PARSE              ,'Y',',FORCE_HARD_PARSE')
         ||decode(c.EXPLAIN_PLAN_CURSOR           ,'Y',',EXPLAIN_PLAN_CURSOR')
         ||decode(c.BUFFERED_DML_MISMATCH         ,'Y',',BUFFERED_DML_MISMATCH')
         ||decode(c.PDML_ENV_MISMATCH             ,'Y',',PDML_ENV_MISMATCH')
         ||decode(c.INST_DRTLD_MISMATCH           ,'Y',',INST_DRTLD_MISMATCH')
         ||decode(c.SLAVE_QC_MISMATCH             ,'Y',',SLAVE_QC_MISMATCH')
         ||decode(c.TYPECHECK_MISMATCH            ,'Y',',TYPECHECK_MISMATCH')
         ||decode(c.AUTH_CHECK_MISMATCH           ,'Y',',AUTH_CHECK_MISMATCH')
         ||decode(c.BIND_MISMATCH                 ,'Y',',BIND_MISMATCH')
         ||decode(c.DESCRIBE_MISMATCH             ,'Y',',DESCRIBE_MISMATCH')
         ||decode(c.LANGUAGE_MISMATCH             ,'Y',',LANGUAGE_MISMATCH')
         ||decode(c.TRANSLATION_MISMATCH          ,'Y',',TRANSLATION_MISMATCH')
         ||decode(c.BIND_EQUIV_FAILURE            ,'Y',',BIND_EQUIV_FAILURE')
         ||decode(c.INSUFF_PRIVS                  ,'Y',',INSUFF_PRIVS')
         ||decode(c.INSUFF_PRIVS_REM              ,'Y',',INSUFF_PRIVS_REM')
         ||decode(c.REMOTE_TRANS_MISMATCH         ,'Y',',REMOTE_TRANS_MISMATCH')
         ||decode(c.LOGMINER_SESSION_MISMATCH     ,'Y',',LOGMINER_SESSION_MISMATCH')
         ||decode(c.INCOMP_LTRL_MISMATCH          ,'Y',',INCOMP_LTRL_MISMATCH')
         ||decode(c.OVERLAP_TIME_MISMATCH         ,'Y',',OVERLAP_TIME_MISMATCH')
         ||decode(c.EDITION_MISMATCH              ,'Y',',EDITION_MISMATCH')
         ||decode(c.MV_QUERY_GEN_MISMATCH         ,'Y',',MV_QUERY_GEN_MISMATCH')
         ||decode(c.USER_BIND_PEEK_MISMATCH       ,'Y',',USER_BIND_PEEK_MISMATCH')
         ||decode(c.TYPCHK_DEP_MISMATCH           ,'Y',',TYPCHK_DEP_MISMATCH')
         ||decode(c.NO_TRIGGER_MISMATCH           ,'Y',',NO_TRIGGER_MISMATCH')
         ||decode(c.FLASHBACK_CURSOR              ,'Y',',FLASHBACK_CURSOR')
         ||decode(c.ANYDATA_TRANSFORMATION        ,'Y',',ANYDATA_TRANSFORMATION')
         ||decode(c.PDDL_ENV_MISMATCH             ,'Y',',PDDL_ENV_MISMATCH')
         ||decode(c.TOP_LEVEL_RPI_CURSOR          ,'Y',',TOP_LEVEL_RPI_CURSOR')
         ||decode(c.DIFFERENT_LONG_LENGTH         ,'Y',',DIFFERENT_LONG_LENGTH')
         ||decode(c.LOGICAL_STANDBY_APPLY         ,'Y',',LOGICAL_STANDBY_APPLY')
         ||decode(c.DIFF_CALL_DURN                ,'Y',',DIFF_CALL_DURN')
         ||decode(c.BIND_UACS_DIFF                ,'Y',',BIND_UACS_DIFF')
         ||decode(c.PLSQL_CMP_SWITCHS_DIFF        ,'Y',',PLSQL_CMP_SWITCHS_DIFF')
         ||decode(c.CURSOR_PARTS_MISMATCH         ,'Y',',CURSOR_PARTS_MISMATCH')
         ||decode(c.STB_OBJECT_MISMATCH           ,'Y',',STB_OBJECT_MISMATCH')
         ||decode(c.CROSSEDITION_TRIGGER_MISMATCH ,'Y',',CROSSEDITION_TRIGGER_MISMATCH')
         ||decode(c.PQ_SLAVE_MISMATCH             ,'Y',',PQ_SLAVE_MISMATCH')
         ||decode(c.TOP_LEVEL_DDL_MISMATCH        ,'Y',',TOP_LEVEL_DDL_MISMATCH')
         ||decode(c.MULTI_PX_MISMATCH             ,'Y',',MULTI_PX_MISMATCH')
         ||decode(c.BIND_PEEKED_PQ_MISMATCH       ,'Y',',BIND_PEEKED_PQ_MISMATCH')
         ||decode(c.MV_REWRITE_MISMATCH           ,'Y',',MV_REWRITE_MISMATCH')
         ||decode(c.ROLL_INVALID_MISMATCH         ,'Y',',ROLL_INVALID_MISMATCH')
         ||decode(c.OPTIMIZER_MODE_MISMATCH       ,'Y',',OPTIMIZER_MODE_MISMATCH')
         ||decode(c.PX_MISMATCH                   ,'Y',',PX_MISMATCH')
         ||decode(c.MV_STALEOBJ_MISMATCH          ,'Y',',MV_STALEOBJ_MISMATCH')
         ||decode(c.FLASHBACK_TABLE_MISMATCH      ,'Y',',FLASHBACK_TABLE_MISMATCH')
         ||decode(c.LITREP_COMP_MISMATCH          ,'Y',',LITREP_COMP_MISMATCH')
         ||decode(c.PLSQL_DEBUG                   ,'Y',',PLSQL_DEBUG')
         ||decode(c.LOAD_OPTIMIZER_STATS          ,'Y',',LOAD_OPTIMIZER_STATS')
         ||decode(c.ACL_MISMATCH                  ,'Y',',ACL_MISMATCH')
         ||decode(c.FLASHBACK_ARCHIVE_MISMATCH    ,'Y',',FLASHBACK_ARCHIVE_MISMATCH')
         ||decode(c.LOCK_USER_SCHEMA_FAILED       ,'Y',',LOCK_USER_SCHEMA_FAILED')
         ||decode(c.REMOTE_MAPPING_MISMATCH       ,'Y',',REMOTE_MAPPING_MISMATCH')
         ||decode(c.LOAD_RUNTIME_HEAP_FAILED      ,'Y',',LOAD_RUNTIME_HEAP_FAILED')
         ||decode(c.HASH_MATCH_FAILED             ,'Y',',HASH_MATCH_FAILED')
         ||decode(c.PURGED_CURSOR                 ,'Y',',PURGED_CURSOR')
         ||decode(c.BIND_LENGTH_UPGRADEABLE       ,'Y',',BIND_LENGTH_UPGRADEABLE')
         ||decode(c.USE_FEEDBACK_STATS            ,'Y',',USE_FEEDBACK_STATS') 
       ,','
      )
        reason
&_if_reason     ,reason reason_xml
from t c
where rn<=&1
order by rn,c.sql_id,c.CHILD_NUMBER
;