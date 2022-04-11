col name for a30;
col status for a10;
prompt Last applied logs:

select sequence#, first_time,next_time,applied,status
from v$archived_log l
where
 first_time>=(	select max(first_time) 
		from v$archived_log l
		where applied='YES'
		)
;
