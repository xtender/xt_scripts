select 
    s.sid
   ,s.serial#
   ,p.spid  as os_pid
   ,p.pid   as ora_pid
from v$session s
    ,v$process p 
where s.PADDR=p.addr 
  and s.sid = userenv('SID')
/