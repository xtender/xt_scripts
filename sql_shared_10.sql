@inc/input_vars_init;
col reason for a120;
select 
     c.inst_id
   , c.SQL_ID
   , c.CHILD_NUMBER
   , ltrim(
           decode(c.UNBOUND_CURSOR           ,'Y',',UNBOUND_CURSOR')
         ||decode(c.SQL_TYPE_MISMATCH        ,'Y',',SQL_TYPE_MISMATCH')
         ||decode(c.OPTIMIZER_MISMATCH       ,'Y',',OPTIMIZER_MISMATCH')
         ||decode(c.OUTLINE_MISMATCH         ,'Y',',OUTLINE_MISMATCH')
         ||decode(c.STATS_ROW_MISMATCH       ,'Y',',STATS_ROW_MISMATCH')
         ||decode(c.LITERAL_MISMATCH         ,'Y',',LITERAL_MISMATCH')
         ||decode(c.SEC_DEPTH_MISMATCH       ,'Y',',SEC_DEPTH_MISMATCH')
         ||decode(c.EXPLAIN_PLAN_CURSOR      ,'Y',',EXPLAIN_PLAN_CURSOR')
         ||decode(c.BUFFERED_DML_MISMATCH    ,'Y',',BUFFERED_DML_MISMATCH')
         ||decode(c.PDML_ENV_MISMATCH        ,'Y',',PDML_ENV_MISMATCH')
         ||decode(c.INST_DRTLD_MISMATCH      ,'Y',',INST_DRTLD_MISMATCH')
         ||decode(c.SLAVE_QC_MISMATCH        ,'Y',',SLAVE_QC_MISMATCH')
         ||decode(c.TYPECHECK_MISMATCH       ,'Y',',TYPECHECK_MISMATCH')
         ||decode(c.AUTH_CHECK_MISMATCH      ,'Y',',AUTH_CHECK_MISMATCH')
         ||decode(c.BIND_MISMATCH            ,'Y',',BIND_MISMATCH')
         ||decode(c.DESCRIBE_MISMATCH        ,'Y',',DESCRIBE_MISMATCH')
         ||decode(c.LANGUAGE_MISMATCH        ,'Y',',LANGUAGE_MISMATCH')
         ||decode(c.TRANSLATION_MISMATCH     ,'Y',',TRANSLATION_MISMATCH')
         ||decode(c.ROW_LEVEL_SEC_MISMATCH   ,'Y',',ROW_LEVEL_SEC_MISMATCH')
         ||decode(c.INSUFF_PRIVS             ,'Y',',INSUFF_PRIVS')
         ||decode(c.INSUFF_PRIVS_REM         ,'Y',',INSUFF_PRIVS_REM')
         ||decode(c.REMOTE_TRANS_MISMATCH    ,'Y',',REMOTE_TRANS_MISMATCH')
         ||decode(c.LOGMINER_SESSION_MISMATCH,'Y',',LOGMINER_SESSION_MISMATCH')
         ||decode(c.INCOMP_LTRL_MISMATCH     ,'Y',',INCOMP_LTRL_MISMATCH')
         ||decode(c.OVERLAP_TIME_MISMATCH    ,'Y',',OVERLAP_TIME_MISMATCH')
         ||decode(c.SQL_REDIRECT_MISMATCH    ,'Y',',SQL_REDIRECT_MISMATCH')
         ||decode(c.MV_QUERY_GEN_MISMATCH    ,'Y',',MV_QUERY_GEN_MISMATCH')
         ||decode(c.USER_BIND_PEEK_MISMATCH  ,'Y',',USER_BIND_PEEK_MISMATCH')
         ||decode(c.TYPCHK_DEP_MISMATCH      ,'Y',',TYPCHK_DEP_MISMATCH')
         ||decode(c.NO_TRIGGER_MISMATCH      ,'Y',',NO_TRIGGER_MISMATCH')
         ||decode(c.FLASHBACK_CURSOR         ,'Y',',FLASHBACK_CURSOR')
         ||decode(c.ANYDATA_TRANSFORMATION   ,'Y',',ANYDATA_TRANSFORMATION')
         ||decode(c.INCOMPLETE_CURSOR        ,'Y',',INCOMPLETE_CURSOR')
         ||decode(c.TOP_LEVEL_RPI_CURSOR     ,'Y',',TOP_LEVEL_RPI_CURSOR')
         ||decode(c.DIFFERENT_LONG_LENGTH    ,'Y',',DIFFERENT_LONG_LENGTH')
         ||decode(c.LOGICAL_STANDBY_APPLY    ,'Y',',LOGICAL_STANDBY_APPLY')
         ||decode(c.DIFF_CALL_DURN           ,'Y',',DIFF_CALL_DURN')
         ||decode(c.BIND_UACS_DIFF           ,'Y',',BIND_UACS_DIFF')
         ||decode(c.PLSQL_CMP_SWITCHS_DIFF   ,'Y',',PLSQL_CMP_SWITCHS_DIFF')
         ||decode(c.CURSOR_PARTS_MISMATCH    ,'Y',',CURSOR_PARTS_MISMATCH')
         ||decode(c.STB_OBJECT_MISMATCH      ,'Y',',STB_OBJECT_MISMATCH')
         ||decode(c.ROW_SHIP_MISMATCH        ,'Y',',ROW_SHIP_MISMATCH')
         ||decode(c.PQ_SLAVE_MISMATCH        ,'Y',',PQ_SLAVE_MISMATCH')
         ||decode(c.TOP_LEVEL_DDL_MISMATCH   ,'Y',',TOP_LEVEL_DDL_MISMATCH')
         ||decode(c.MULTI_PX_MISMATCH        ,'Y',',MULTI_PX_MISMATCH')
         ||decode(c.BIND_PEEKED_PQ_MISMATCH  ,'Y',',BIND_PEEKED_PQ_MISMATCH')
         ||decode(c.MV_REWRITE_MISMATCH      ,'Y',',MV_REWRITE_MISMATCH')
         ||decode(c.ROLL_INVALID_MISMATCH    ,'Y',',ROLL_INVALID_MISMATCH')
         ||decode(c.OPTIMIZER_MODE_MISMATCH  ,'Y',',OPTIMIZER_MODE_MISMATCH')
         ||decode(c.PX_MISMATCH              ,'Y',',PX_MISMATCH')
         ||decode(c.MV_STALEOBJ_MISMATCH     ,'Y',',MV_STALEOBJ_MISMATCH')
         ||decode(c.FLASHBACK_TABLE_MISMATCH ,'Y',',FLASHBACK_TABLE_MISMATCH')
         ||decode(c.LITREP_COMP_MISMATCH     ,'Y',',LITREP_COMP_MISMATCH')
      ,',')
   as  reason
from gv$sql_shared_cursor c
where c.sql_id='&1'
order by inst_id,child_number
/
col reason clear;
@inc/input_vars_undef;
