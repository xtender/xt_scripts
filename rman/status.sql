select * 
from v$rman_status 
where start_time>=sysdate-5 
order by start_time desc;
