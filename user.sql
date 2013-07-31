col username    format  a18
col osuser      format  a18
col program     format  a15

col sql_fulltext format a150

select sid,serial#,username,osuser,program,status,state,event,s.sql_id,sql_fulltext
from v$session s, v$sqlarea a
where 
   (   upper(s.username) like upper('%&1%') 
    or upper(s.osuser) like upper('%&1%')
   )
   and s.sql_id=a.sql_id(+)
   ;
col username    clear
col osuser      clear
col program     clear

col sql_fulltext clear
