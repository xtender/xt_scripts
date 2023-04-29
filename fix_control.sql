col bugno                       format 99999999
col SQL_FEATURE                 format a35
col value                       format 999
col description                 format a80
col OPTIMIZER_FEATURE_ENABLE    format a12 head OPT_FEAT_ENA
col EVENT                       format 999999999
col IS_DEFAULT                  format 999
select bugno,value,sql_feature,description
   ,optimizer_feature_enable
   ,event,is_default 
from v$system_fix_control 
where lower(description)    like lower('%&1%')
   or EVENT                 like '&1' 
   or bugno                 like '&1' 
&&_IF_ORA11_OR_HIGHER   or lower(SQL_FEATURE      )   like lower('&1')
&&_IF_ORA11_OR_HIGHER   or OPTIMIZER_FEATURE_ENABLE   like lower('&1')
order by
&&_IF_ORA11_OR_HIGHER   SQL_FEATURE, 
                        OPTIMIZER_FEATURE_ENABLE, bugno
/
col bugno                       clear
col SQL_FEATURE                 clear
col value                       clear
col description                 clear
col OPTIMIZER_FEATURE_ENABLE    clear
col EVENT                       clear
col IS_DEFAULT                  clear