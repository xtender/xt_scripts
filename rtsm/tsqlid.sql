prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SQL_ID &1....
@sqlplus_store
set termout off timing off ver off feed off head off lines 10000000 pagesize 0
@@xprof ALL TEXT SQL_ID "'&1'"
@sqlplus_restore