select
  w.event
 ,w.WAIT_CLASS
 ,w.STATE
 ,count(distinct w.SID)
 ,min(w.SECONDS_IN_WAIT)
 ,max(w.SECONDS_IN_WAIT)
 ,avg(w.SECONDS_IN_WAIT)
from v$session_wait w
group by   w.event
          ,w.WAIT_CLASS
          ,w.STATE
order by 4 desc
/