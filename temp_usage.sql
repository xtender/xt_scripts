col TABLESPACE format a20
col CONTENTS   format a15
col SQL_ID     format a13
col SQLADDR    format a16
col SEGTYPE    format a12

select 
  s.sid
 ,u.SQLADDR
 ,u.SQL_ID
 ,u.TABLESPACE
 ,u.CONTENTS
 ,u.SEGTYPE
 ,u.BLOCKS
 ,to_char(u.BLOCKS*8192/1e6,'tm9') "mem(Mbytes)"
from v$tempseg_usage u
    ,v$session s 
where u.SESSION_ADDR=s.SADDR 
  and s.sid=&sid
/