alter session set MAX_DUMP_FILE_SIZE = unlimited;
alter session set events '10128 [sql:&sqlid] level 15';
alter session set tracefile_identifier='&trace_identifier';
