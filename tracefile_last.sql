@inc/input_vars_init;
col adr_home       for a40;
col change_time    for a15;
col modify_time    for a15;
col trace_filename for a40;
select
     adr_home
    ,trace_filename
    ,to_char(change_time,'mon/dd hh24:mi:ss') change_time
    ,to_char(modify_time,'mon/dd hh24:mi:ss') modify_time
from V$DIAG_TRACE_FILE 
order by change_time desc
fetch first nvl2('&1',&1+0,10) rows only;
@inc/input_vars_undef