
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
col USE_FEEDBACK_STATS      format a8 heading FEEDBACK     ;
col reason                  format a30 heading reason                 ;

select c.SQL_ID
      ,c.CHILD_NUMBER           
      ,c.sql_type_mismatch      
      ,c.OPTIMIZER_MISMATCH     
      ,c.OUTLINE_MISMATCH       
      ,c.STATS_ROW_MISMATCH     
      ,c.LITERAL_MISMATCH       
      ,c.BIND_MISMATCH          
      ,c.REMOTE_TRANS_MISMATCH  
      ,c.USER_BIND_PEEK_MISMATCH
      ,c.OPTIMIZER_MODE_MISMATCH
      ,c.USE_FEEDBACK_STATS     
      ,c.reason            
from v$sql_shared_cursor c
where c.sql_id like '&1'
;