col description for a80;
col error       for 99999;
col state       for a12;
col status      for a12;
col wait_class  for a12;
col event       for a50;
select--+ leading(p s) use_nl(s)
    p.name        as bg_pname
   ,p.description
   ,p.error
   ,s.sid
   ,s.serial#
   ,s.state
   ,s.status
   ,s.wait_class
   ,s.event
from v$bgprocess p
    ,v$session s
where
    p.paddr !='00'
and p.paddr=s.paddr(+);

col description clear;
col error       clear;
col state       clear;
col status      clear;
col wait_class  clear;
col event       clear;