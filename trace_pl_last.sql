col event_comment format a80
select 
   runid,event_seq,event_comment,event_unit_owner,event_unit
from plsql_trace_events e
where e.runid=(select max(runid) from plsql_trace_runs)
;
col event_comment clear