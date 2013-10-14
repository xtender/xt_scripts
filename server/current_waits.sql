col event       format a40;
col WAIT_CLASS  format a15;
col STATE       format a25;
col WAITING     format 999;
col SHORT       format 999;
col KNOWN       format 999;

select
  w.event
 ,w.WAIT_CLASS
 ,count(distinct w.SID)                      sessions
 ,count(*)                                   count
 ,count(decode(STATE,'WAITING'          ,1)) WAITING
 ,count(decode(STATE,'WAITED SHORT TIME',1)) SHORT
 ,count(decode(STATE,'WAITED KNOWN TIME',1)) KNOWN
 ,min(w.WAIT_TIME_MICRO) min_time_micro
 ,max(w.WAIT_TIME_MICRO) max_time_micro
 ,avg(w.WAIT_TIME_MICRO) avg_time_micro
from v$session_wait w
where WAIT_CLASS!='Idle'
group by   w.event
          ,w.WAIT_CLASS
order by 4 desc
/
col event clear;
col WAIT_CLASS  clear;
col STATE       clear;
col WAITING     clear;
col SHORT       clear;
col KNOWN       clear;