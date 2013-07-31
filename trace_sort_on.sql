alter session set max_dump_file_size=unlimited;
ALTER SESSION SET tracefile_identifier = '&trace_ident';
ALTER SESSION SET EVENTS '10032 trace name context forever, level 10';
