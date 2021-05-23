@inc/input_vars_init;
col adr_home       for a80;
col trace_filename for a40;
select
    adr_home,
    trace_filename
from V$DIAG_TRACE_FILE 
where lower(trace_filename) like lower('%&1%')
order by change_time desc
fetch first 10 rows only;
@inc/input_vars_undef;