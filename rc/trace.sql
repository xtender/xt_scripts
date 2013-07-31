alter session set MAX_DUMP_FILE_SIZE = unlimited;
alter session set tracefile_identifier='&trace_identifier';
--alter session set events '10046 trace name context forever, level &level';
ALTER SESSION SET EVENTS '43905 trace name context forever, level 1';
ALTER SESSION SET EVENTS '43906 trace name context forever, level 1';
