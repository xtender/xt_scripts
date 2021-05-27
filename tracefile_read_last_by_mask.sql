@inc/input_vars_init;
prompt *** Read last tracefile by change_time with a filter
prompt * Usage:
prompt * @tracefile_read_last_by_mask filemask [regexp] [ignore_regexp]
prompt *****************************************************

set echo off;
col adr_home       for a40;
col trace_filename for a40 new_val tracefile;
select
    adr_home,
    trace_filename,
    to_char(change_time,'mon/dd hh24:mi:ss') change_time,
    to_char(modify_time,'mon/dd hh24:mi:ss') modify_time
from V$DIAG_TRACE_FILE 
where lower(trace_filename) like lower('%&1%')
order by change_time desc
fetch first 1 rows only;

col payload		for a300;
select payload
from V$DIAG_TRACE_FILE_CONTENTS
where 
     trace_filename like '&tracefile'
 and function_name!='dbktWriteTimestampWCdbInfo'
 and ('&2' is null or regexp_like(payload, '&2'))
 and ('&3' is null or not regexp_like(payload, '&3'))
;

@inc/input_vars_undef;