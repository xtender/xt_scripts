col param         format a30;
col param_value   format a100;
with params as (
     select column_value param 
     from table(
            sys.ku$_vcnt(
                'AUTOSTATS_TARGET'
              , 'CASCADE'
              , 'DEGREE'
              , 'ESTIMATE_PERCENT'
              , 'METHOD_OPT'
              , 'NO_INVALIDATE'
              , 'GRANULARITY'
&_IF_ORA112_OR_HIGHER , 'PUBLISH'
&_IF_ORA112_OR_HIGHER , 'INCREMENTAL'
&_IF_ORA112_OR_HIGHER , 'STALE_PERCENT'
           ))
)
select
    param
  , DBMS_STATS.GET_PARAM (param) param_value
from params;
col param         clear;
col param_value   clear;
