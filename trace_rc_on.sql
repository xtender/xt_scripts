alter session set timed_statistics = true;
alter session set MAX_DUMP_FILE_SIZE = unlimited;
alter session set tracefile_identifier='&trace_identifier';
--ORA-10843: Event for client result cache tracing
--alter session set events '10843 trace name context forever, level 1';

-- ORA-43905: result cache tracing event - it doesn't work anymore. Use trace[Result_Cache] instead.
--alter session set events '43905 trace name context forever, level 1';
alter session set events 'trace[Result_Cache] disk = highest';