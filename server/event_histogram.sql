col event format a50;
select *
from v$event_histogram eh
where upper(eh.EVENT) like upper('%&1%');
col event clear;
