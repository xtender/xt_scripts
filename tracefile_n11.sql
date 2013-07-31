col tracefile format a100
select 
   value 
   ||'/'
   ||(select lower(instance_name) from v$instance) 
   ||'_ora_'
   ||(select spid from v$process where addr = (select paddr from v$session where sid = nvl('&1'+0,userenv('sid'))))
   || '.trc' tracefile
from v$parameter 
where name = 'user_dump_dest';

col tracefile clear
