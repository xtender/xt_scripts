@inc/input_vars_init;
define A_SQLID=&1

var c_out clob;

col p_awr   new_value p_awr;
col p_vsql  new_value p_vsql;
select 
   case when '&2 &3 &4 &5'     like '%+awr%'   then 'true'  else 'false' end p_awr
  ,case when '&2 &3 &4 &5' not like '%-v$sql%' then 'true'  else 'false' end p_vsql
from dual;

exec  :c_out:=xt_plans.get_plans('&A_SQLID', p_awr => '&p_awr',p_v$sql=>'&p_vsql');

set termout off timing off ver off feed off head off lines 10000000 pagesize 0
spool &_TEMPDIR\plans_&A_SQLID..html
print c_out
spool off
host &_START &_TEMPDIR\plans_&A_SQLID..html
undef A_SQLID
@inc/input_vars_undef;
