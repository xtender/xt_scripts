select 
    s.sid
   ,s.serial#
   ,s.osuser
   ,s.username
   ,s.program
   ,s.module
   ,s.machine
   ,s.terminal
   ,p.spid
   ,p.pid 
from v$session s
    ,v$process p 
where s.PADDR=p.addr 
  and p.spid = &1
/