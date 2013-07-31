prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SID &1.... (11.2+)
@sqlplus_store
set termout off timing off ver off feed off head off lines 10000000 pagesize 0
define MONSID=&1
spool &_TEMPDIR\xprof_&MONSID..html

@@xprof ALL ACTIVE SESSION_ID &MONSID

spool off

host &_START &_TEMPDIR\xprof_&MONSID..html
@sqlplus_restore
