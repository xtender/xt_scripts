@inc/input_vars_init
set termout off timing off ver off feed off head off lines 10000000 pagesize 0

define _sqlid=&1

col exec new_val exec noprint;
col html new_val html noprint;

with plans as (
               select distinct sql_id,plan_hash_value as plan_hv,p.timestamp
               from dba_hist_sql_plan p where p.sql_id='&_sqlid' and dbid=&DB_ID
)
select 
   listagg('@inc/awr_active "'||p.sql_id||'" "'||p.plan_hv||'"'
           ,chr(10)
          ) within group(order by p.timestamp)
    as exec
  ,listagg('<td>plan_hv='||p.plan_hv||'<br/>'
           ||'<iframe '
                    ||' src="./plan_awr_'||p.sql_id||'_'||p.plan_hv||'.html" '
                    ||' width="700" height="2000" '
           ||'></iframe></td>'
          ,chr(10)
          ) within group(order by p.timestamp)
    as html
from plans p;

define _efile='&_TEMPDIR\plan_awr_&_sqlid..sql'
spool &_efile
prompt &exec
spool off
@&_efile

define _hfile="&_TEMPDIR\plan_awr_&_sqlid..html"
spool &_hfile
prompt <html><body><table border=1><tr>
prompt &html
prompt </tr></table></body></html>
spool off
host &_START &_hfile

undef _sqlid _hfile _efile exec
@inc/input_vars_undef
