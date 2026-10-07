alter session set timed_statistics = true;
alter session set MAX_DUMP_FILE_SIZE = unlimited;
col trace_identifier new_val trace_identifier;
select 'opt_trace_'||to_char(sysdate,'yyyymmdd_hh24miss') trace_identifier from dual;
alter session set tracefile_identifier='&trace_identifier';
alter session set events '10053 trace name context forever, level 1';
