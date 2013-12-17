col sql_text format a120 word;
select * 
from (
     select s.sql_id, s.sql_text,s.elapsed_time/s.executions/1e6 elaexe from v$sqlarea s where s.executions>0 and command_type=3
     order by 3 desc
     )
where rownum<=10;

col sql_text clear;