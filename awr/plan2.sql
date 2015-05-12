col xplan for a200;
select distinct dbid, sql_id,plan_hash_value from dba_hist_sqlstat st where st.sql_id='&1'
/

with plans as (
select distinct dbid, sql_id,plan_hash_value from dba_hist_sqlstat st where st.sql_id='&1'
)
select
  dbms_xplan.display_plan(
     'DBA_HIST_SQL_PLAN'
    ,null
    ,'advanced'
    ,'sql_id='''||sql_id||''' and plan_hash_value='||plan_hash_value
    ,'text'
    ) xplan
from plans;
col xplan clear;
