define _sqlid=&1
define _plan_vh='&2'
define _fname="&_TEMPDIR\plan_awr_&_sqlid._&_plan_vh..html"
spool &_fname

select
   dbms_xplan.display_plan(
                  table_name   => 'DBA_HIST_SQL_PLAN'
                 ,format       => 'ADVANCED'
                 ,filter_preds => q'[dbid = &DB_ID and sql_id = '&_sqlid' and plan_hash_value='&_plan_vh']'
                 ,type         => 'ACTIVE'
                ) plan
from dual;

spool off
undef _fname 