col rtsm_sql_id new_val rtsm_sql_id;
select max(sql_id) keep(dense_rank first order by sql_exec_start desc) rtsm_sql_id from v$sql_monitor m where m.sid=userenv('sid');
@@sqlid &rtsm_sql_id;