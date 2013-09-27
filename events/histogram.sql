prompt *** Wait events histogram
prompt * Usage @histogram event#
prompt * or    @histogram event_name

col event format a40;

select * 
from v$event_histogram e
where translate('&1','x0123456789','x') is null
and '&1' is not null
and e.EVENT#='&1'+0
union all
select * 
from v$event_histogram e
where translate('&1','x0123456789','x') is not null
and e.EVENT like '&1%'
;
col event clear;