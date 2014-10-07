col event format a64
col P1TEXT format a20
col P2TEXT format a20
col P3TEXT format a20
select 
                        swh.EVENT
                       ,swh.seq#
                       ,swh.P1TEXT,swh.p1
                       ,swh.P2TEXT,swh.p2
                       ,swh.P3TEXT,swh.p3
                       ,swh.wait_time
&_IF_ORA11_OR_HIGHER   ,swh.WAIT_TIME_MICRO
&_IF_ORA11_OR_HIGHER   ,swh.TIME_SINCE_LAST_WAIT_MICRO time_since
from v$session_wait_history  swh
where sid=&1
/
undef 1