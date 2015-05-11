@inc/input_vars_init;
prompt &_C_REVERSE ***                Show plan from awr              *** &_C_RESET
prompt 
prompt Syntax: @awr/plan sql_id [format [plan_hash_value [dbid]] ]

select * 
from table(
   dbms_xplan.display_awr(/*sql_id          => */ '&1'
                         ,/*plan_hash_value => */ '&3'
                         ,/*db_id           => */ '&4' --'&DB_ID'
                         ,/*format          => */  nvl('&2','advanced')
                         )
  );
@inc/input_vars_undef;
