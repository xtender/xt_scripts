set feed off
col tracefile_name format a150;
alter session set timed_statistics = true;
alter session set MAX_DUMP_FILE_SIZE = unlimited;
alter session set tracefile_identifier='&trace_identifier';
alter session set events '10046 trace name context forever, level &level';
prompt Tracing was enabled:
select par.value ||'/'||(select instance_name from v$instance) ||'_ora_'||s.suffix|| '.trc' as tracefile_name
from 
    v$parameter par
  , (select spid||case when traceid is not null then '_'||traceid else null end suffix
     from v$process where addr = (select paddr from v$session
                                  where sid = userenv('sid')
                                ) 
    ) s
where name = 'user_dump_dest';
set feed on