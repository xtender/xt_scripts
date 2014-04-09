prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_DETAIL for SQL_ID='&1'....

@inc/input_vars_init;
set termout off timing off ver off feed off head off lines 10000000 pagesize 0
-------------------------
define MONSQLID=&1
spool &_TEMPDIR\xprof_d_&MONSQLID..html

@@xprof_d ALL ACTIVE SQL_ID "'&MONSQLID'"

spool off
host &_START &_TEMPDIR\xprof_d_&MONSQLID..html
-------------------------
undef MONSQLID
@inc/input_vars_undef;