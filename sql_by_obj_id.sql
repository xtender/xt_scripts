col sql_text format a100
select 
   s.SQL_ID
  ,s.ELAPSED_TIME/1e6/nullif(s.EXECUTIONS,0) as elaexe
  ,s.EXECUTIONS                              as execs
  ,case 
     when length(sql_text)>97 
       then substr(s.SQL_TEXT,1,97)||'...'
     else sql_text
   end                                       as sql_text
  ,s.PROGRAM_ID
  ,s.PROGRAM_LINE#
from v$sqlarea s 
where s.PROGRAM_ID=&1
order by PROGRAM_LINE#
/
col sql_text clear;
