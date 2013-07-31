select distinct sql_id
from v$active_session_history h
where h.session_id=&1
and h.sample_time>sysdate - interval '&2' minute;