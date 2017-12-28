propmt * Run as SYS:
accept HPROF_USER prompt "HPROF_USER: ";
accept HPROF_DIR  prompt "HPROF_DIR: ";
accept dbname prompt "Connection string: ";

CREATE OR REPLACE DIRECTORY HPROF_DIR as '&HPROF_DIR';
GRANT READ, WRITE ON DIRECTORY HPROF_DIR TO &HPROF_USER;
GRANT EXECUTE ON dbms_hprof TO &HPROF_USER;

prompt * Run as HPROF_USER:
conn &HPROF_USER@&dbname;
@?/rdbms/admin/dbmshptab.sql
