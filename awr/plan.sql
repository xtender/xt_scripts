@inc/input_vars_init;
prompt &_C_REVERSE ***                Show plan from awr              *** &_C_RESET
prompt 
prompt Syntax: @awr/plan sql_id [format [plan_hash_value [dbid]] ]
col PLAN_TABLE_OUTPUT for a180;
break on dbid skip 1;

with dbids as (select distinct dbid from dba_hist_sqlstat st where st.sql_id='&1' and ('&4' is null or dbid=to_number('&4')))
select * 
from 
   dbids
  ,table(
       dbms_xplan.display_awr(/*sql_id          => */ '&1'
                             ,/*plan_hash_value => */ '&3'
                             ,/*db_id           => */ dbids.dbid
                             ,/*format          => */  nvl('&2','advanced')
                             )
      );
clear break;
clear col;
@inc/input_vars_undef;
