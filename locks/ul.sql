set pagesize 999

column username format a30
column program format a13
column machine format a22
column terminal format a18
column ctime format a9

select--+ ordered
       l.ID1
      ,l.type
      ,s.sid
      ,s.serial#
      ,s.username
      ,s.PROGRAM
      ,s.MACHINE
      ,s.TERMINAL
      ,trunc(l.ctime/60/60)
      ||'h:'||to_char(trunc(mod(l.ctime/60,60)),'FM00')
      ||':'||to_char(mod(l.ctime,60),'FM00') ctime
from  v$lock l
     ,v$session s
where l.type='UL' and 
      s.sid=l.sid
/
