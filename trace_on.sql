alter session set timed_statistics = true;
alter session set MAX_DUMP_FILE_SIZE = unlimited;
alter session set tracefile_identifier='&trace_identifier';
alter session set events '10046 trace name context forever, level &level';
