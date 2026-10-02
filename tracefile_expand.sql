col tracefile_name format a100;
SELECT VALUE as tracefile_name FROM V$DIAG_INFO WHERE NAME = 'Default Trace File';
col tracefile_name clear;
col payload		for a300 word head "Final query after transformations:";

select
   cur_sql_id||':'||chr(10)
  ||payload as payload
from (
  select 
    v.*
   ,max(chk)over(order by rn) last_rn
   ,last_value(sql_id ignore nulls)over(order by rn) cur_sql_id
  from (
    select--+ leading(i f c) use_nl(f) use_nl(c)
      payload
     ,rownum rn
     ,case when payload like 'Final query after transformations%' then rownum end chk 
     ,regexp_substr(payload,'sql_id=(\S{13})',1,1,null,1) as sql_id
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
--  rn between last_rn and last_rn+1
  rn = last_rn+1
;