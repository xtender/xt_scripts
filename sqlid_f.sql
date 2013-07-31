@inc/input_vars_init;
-----------------------------------------
--    params check:
set termout off timing off
def _sqlid=&1
col _child new_val _child noprint
select 
   case 
      when translate('&2','x0123456789','x') is null  
         then nvl('&2','%') 
      else '%'
   end "_CHILD"
from dual;
-----------------------------------------
set termout on
--    tpt/sql_id:
col error_message   for a40
prompt ################################  Query text Start  ################################################;
set termout off timing off head off 
spool &_TEMPDIR./to_format.sql
select 
    --sql_text        sql_sql_text
    SQL_FULLTEXT    sql_sql_text
from 
    v$sqlarea
where 
    sql_id = ('&1')
and rownum<2
/
spool off
set termout on head on
$perl ./inc/sql_format.pl &_TEMPDIR./to_format.sql

prompt ################################  Query text End ###################################################
---------------------------------------
--    clearing:
col SQL_PROFILE     clear
col owner           clear
col object_name     clear
col text            clear
col error_message   clear
@inc/input_vars_undef;