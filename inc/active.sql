define _sqlid  =&1
define _child  ='&2'
define _plan_vh='&3'
define _fname="&_TEMPDIR\plan_lc_&_sqlid._&_plan_vh._&_child..html"
spool &_fname

select
   dbms_xplan.display_plan(
                  table_name   => 'v$sql_plan_statistics_all'
                 ,format       => 'ADVANCED'
                 ,filter_preds => q'[sql_id = '&_sqlid' and child_number=&_child and plan_hash_value='&_plan_vh']'
                 ,type         => 'ACTIVE'
                ) plan
from dual;

spool off
undef _fname 