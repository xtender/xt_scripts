
col SQL_PROFILE         format a20
col SQL_PATCH           format a30
col SQL_PLAN_BASELINE   format a30
col CHILD_NUMBER        format 99
col PLAN_HASH_VALUE     format 9999999999
col EXECUTIONS          format 9999999
col elaexe              format 9999.99

select 
                         s.sql_id
                        ,s.CHILD_NUMBER
                        ,s.PLAN_HASH_VALUE
&_IF_ORA10_OR_HIGHER    ,s.SQL_PROFILE 
&_IF_ORA112_OR_HIGHER   ,s.SQL_PATCH
&_IF_ORA11_OR_HIGHER    ,s.SQL_PLAN_BASELINE
                        ,s.EXECUTIONS
                        ,decode(s.EXECUTIONS,0,0,s.ELAPSED_TIME/1e6/s.EXECUTIONS) elaexe
from v$sql s 
where s.SQL_ID = '&1'
/
