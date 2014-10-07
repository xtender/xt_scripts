prompt *** Wait events histogram
prompt * Usage @histogram event#
prompt * or    @histogram event_name

col event format a40;
col LAST_UPDATE_TIME for a35;
col pct for 999.00;
col running_pct for 999.00;
select e.*
      ,round(WAIT_COUNT*100/sum(WAIT_COUNT)over(partition by event),2) pct
      ,round(sum(WAIT_COUNT)over(partition by event order by EVENT#,EVENT,WAIT_TIME_MILLI)*100/sum(WAIT_COUNT)over(partition by event),2) running_pct
from v$event_histogram e
where translate('&1','x0123456789','x') is null
and '&1' is not null
and e.EVENT#='&1'+0
union all
select e.*
      ,round(WAIT_COUNT*100/sum(WAIT_COUNT)over(partition by event),2) pct
      ,round(sum(WAIT_COUNT)over(partition by event order by EVENT#,EVENT,WAIT_TIME_MILLI)*100/sum(WAIT_COUNT)over(partition by event),2) running_pct
from v$event_histogram e
where translate('&1','x0123456789','x') is not null
and e.EVENT like '&1%'
order by 1,2,3
;
col event clear;
col LAST_UPDATE_TIME clear;
col pct clear;
col running_pct clear;