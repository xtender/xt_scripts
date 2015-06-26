set feed off
col tracefile_name format a150;
alter session set timed_statistics = true;
alter session set MAX_DUMP_FILE_SIZE = unlimited;
alter session set tracefile_identifier='&trace_identifier';
alter session set events '10046 trace name context forever, level &level';
prompt Tracing was enabled:

&_IF_ORA11_OR_HIGHER  SELECT VALUE as tracefile_name FROM V$DIAG_INFO WHERE NAME = 'Default Trace File';

&_IF_LOWER_THAN_ORA11 select par.value ||'/'||(select instance_name from v$instance) ||'_ora_'||s.suffix|| '.trc' as tracefile_name
&_IF_LOWER_THAN_ORA11 from 
&_IF_LOWER_THAN_ORA11     v$parameter par
&_IF_LOWER_THAN_ORA11   , (select spid||case when traceid is not null then '_'||traceid else null end suffix
&_IF_LOWER_THAN_ORA11      from v$process where addr = (select paddr from v$session
&_IF_LOWER_THAN_ORA11                                   where sid = userenv('sid')
&_IF_LOWER_THAN_ORA11                                 ) 
&_IF_LOWER_THAN_ORA11     ) s
where name = 'user_dump_dest';
set feed on