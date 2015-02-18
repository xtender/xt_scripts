col sql_text format a100
col sql_profile         head Profile/Baseline/Patch   for a30;

select 
   s.SQL_ID
  ,s.sql_profile
&_IF_ORA11_OR_HIGHER ||' / '||s.sql_plan_baseline
&_IF_ORA11_OR_HIGHER ||' / '||s.sql_patch
   as sql_profile
  ,s.ELAPSED_TIME/1e6/nullif(s.EXECUTIONS,0) as elaexe
  ,s.EXECUTIONS                              as execs
  ,case 
     when length(sql_text)>97 
       then substr(s.SQL_TEXT,1,97)||'...'
     else sql_text
   end                                       as sql_text
  ,s.PROGRAM_ID
  ,s.PROGRAM_LINE#
from v$sql s 
where                   upper(s.sql_profile)        like upper('%&1%')
&_IF_ORA11_OR_HIGHER or upper(s.sql_plan_baseline)  like upper('%&1%')
&_IF_ORA11_OR_HIGHER or upper(s.sql_patch)          like upper('%&1%')
order by PROGRAM_LINE#
/
col sql_text clear;
col sql_profile clear;