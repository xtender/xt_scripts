@inc/input_vars_init;
prompt &_C_REVERSE ***                Show plan from awr              *** &_C_RESET
prompt 
prompt Syntax: @awr/plan sql_id [format [plan_hash_value [dbid]] ]

col dbid    new_val awr_dbid     noprint;
col dbname  new_val awr_dbname   noprint;
col plan_hv new_val awr_plan_hv  noprint;

col PLAN_TABLE_OUTPUT for a180;

break on dbid on dbname on plan_hash_value skip page;
ttitle -
   '###############################################################################' skip 1 -
   '    DBID:    ' awr_dbid      skip 1 -
   '    DBNAME:  ' awr_dbname    skip 1 -
   '    PLAN_HV: ' awr_plan_hv   skip 1 -
   '###############################################################################' skip 1 -
   '' skip 2;


with dbids as (select distinct dbid,plan_hash_value plan_hv from dba_hist_sqlstat st where st.sql_id='&1' and ('&4' is null or dbid=to_number('&4')))
select 
    dbids.dbid 
   ,(select max(db_name)keep(dense_rank first order by startup_time desc)
     from dba_hist_database_instance i 
     where i.dbid=dbids.dbid
    ) dbname
   ,dbids.plan_hv
   ,t2.*
from 
   dbids
  ,table(
       dbms_xplan.display_awr(/*sql_id          => */ '&1'
                             ,/*plan_hash_value => */ dbids.plan_hv
                             ,/*db_id           => */ dbids.dbid
                             ,/*format          => */  nvl('&2','advanced')
                             )
      )(+) t2;
clear break;
ttitle off;
col dbid    clear;
col dbname  clear;
col plan_hv clear;
@inc/input_vars_undef;
