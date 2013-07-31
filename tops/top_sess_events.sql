select 
     s.sid
    ,s.username
    ,s.SCHEMANAME "SCHEMA"
    ,s.OSUSER
    ,s.MACHINE
    ,s.ACTION
    ,se.wait_class
    ,se.event
    ,se.total_waits               tot_waits
    ,se.total_timeouts            tot_timeouts
    ,round (se.time_waited/100,4) "waited(secs)"
--    ,se.time_waited_micro
    ,se.average_wait              avg_wait
    ,round(se.max_wait/100,4)     max_wait
--   others:
    ,s.module,s.program
    ,s.TERMINAL
    ,s.CLIENT_INFO
    ,s.CLIENT_IDENTIFIER
from v$session_event se
    ,v$session s
where 
       upper(se.event) like '%&1%'
   and se.sid=s.sid
   and s.wait_class!='Idle'
order by time_waited desc
/
