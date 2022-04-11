col name for a30;
col status for a10;
prompt Last logs:
select sequence#, first_time,next_time,applied,status
from v$archived_log l
where 1=1
order by first_time desc
fetch first 10 rows only
;
