col WAIT_CLASS for a20;
col event      for a64;

break on report;
COMPUTE sum LABEL " = = TOTAL = = " OF cnt ON REPORT;

with sw as (
   select
      decode(state, 'WAITING', WAIT_CLASS , 'ON CPU') WAIT_CLASS,
      decode(state, 'WAITING', event , null)          event
   from v$session_wait
   where wait_class!='Idle'
)
select 
    WAIT_CLASS
   ,event
   ,count(*) cnt
from sw
group by WAIT_CLASS,event
ORDER BY cnt desc
/
col wait_class clear;
col event      clear;
clear break;
clear computes;
