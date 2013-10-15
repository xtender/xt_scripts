@inc/input_vars_init
set termout off timing off ver off feed off head off lines 10000000 pagesize 0

define A_SQLID=&1
spool &_TEMPDIR\plan_&A_SQLID..html

select
   dbms_xplan.display_plan(
                  table_name   => 'DBA_HIST_SQL_PLAN'
                 ,format       => 'ADVANCED'
                 ,filter_preds => q'[dbid = 3126056015 and sql_id = '&A_SQLID' and plan_hash_value=1243306242]'
                 ,type         => 'ACTIVE'
                ) plan
from dual;

spool off
host &_START &_TEMPDIR\plan_&A_SQLID..html
undef A_SQLID
@inc/input_vars_undef