col tracefile_name format a100;
SELECT VALUE as tracefile_name FROM V$DIAG_INFO WHERE NAME = 'Default Trace File';
col tracefile_name clear;
col payload		for a300;

select *
from (
  select 
    v.*
   ,max(chk)over(order by rn) last_rn
  from (
    select--+ leading(i f c) use_nl(f) use_nl(c)
      payload
     ,rownum rn
     ,case when payload like 'Final query after transformations%' then rownum end chk 
    from
         V$DIAG_INFO i
        ,V$DIAG_TRACE_FILE f
        ,V$DIAG_TRACE_FILE_CONTENTS c
    where 1=1
     and i.NAME = 'Default Trace File'
     and i.value   like '%'||f.trace_filename
     and f.adr_home       = c.adr_home
     and f.trace_filename = c.trace_filename
     and c.session_id=userenv('sid')
     and c.serial#=DBMS_DEBUG_JDWP.CURRENT_SESSION_SERIAL
     and function_name!='dbktWriteTimestampWCdbInfo'
  ) v
)v2
where
  rn between last_rn and last_rn+1
;