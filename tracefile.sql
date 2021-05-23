col tracefile_name format a100
SELECT
&_IF_ORA11_OR_HIGHER  VALUE as tracefile_name FROM V$DIAG_INFO WHERE NAME = 'Default Trace File'
&_IF_LOWER_THAN_ORA11 par.value ||'/'||(select instance_name from v$instance) ||'_ora_'||s.suffix|| '.trc' as tracefile_name
&_IF_LOWER_THAN_ORA11 from
&_IF_LOWER_THAN_ORA11     v$parameter par
&_IF_LOWER_THAN_ORA11   , (select spid||case when traceid is not null then '_'||traceid else null end suffix
&_IF_LOWER_THAN_ORA11      from v$process where addr = (select paddr from v$session
&_IF_LOWER_THAN_ORA11                                   where sid = userenv('sid')
&_IF_LOWER_THAN_ORA11                                 )
&_IF_LOWER_THAN_ORA11     ) s
&_IF_LOWER_THAN_ORA11 where name = 'user_dump_dest'
/

col tracefile_name clear
