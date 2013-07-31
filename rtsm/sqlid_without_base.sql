prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SQL_ID='&1'....

@inc/input_vars_init
set termout off timing off ver off feed off head off lines 10000000 pagesize 0

define MONSQLID=&1
spool &_TEMPDIR\xprof_&MONSQLID..html

@@xprof_without_base ALL ACTIVE SQL_ID "'&MONSQLID'"

spool off
host &_START &_TEMPDIR\xprof_&MONSQLID..html
undef MONSQLID
@inc/input_vars_undef