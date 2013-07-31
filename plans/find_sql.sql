set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a41
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col etime format 9,999,999.99

select sql_id, child_number, plan_hash_value plan_hash, executions execs, elapsed_time/1000000 etime
	,(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, u.username
	,sql_text
from v$sql s, dba_users u
where upper(sql_text) like upper(nvl('&sql_text',sql_text))
	and sql_text not like 'select sql_id,%'
	and sql_id like nvl('&sql_id',sql_id)
	and u.user_id = s.parsing_user_id
/
