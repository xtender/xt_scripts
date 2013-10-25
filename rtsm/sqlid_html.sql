prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SQL_ID='&1'....

@inc/input_vars_init
set termout off timing off ver off feed off head off lines 10000000 pagesize 0
-------------------------
-- workaround for bug with:
-- ORA-06502: PL/SQL: numeric or value error
-- ORA-06512: at "SYS.DBMS_SQLTUNE", line 14265
col nls_num_chars new_val nls_num_chars noprint;
select value nls_num_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
alter session set nls_numeric_characters='.,';
-------------------------
define MONSQLID=&1
spool &_TEMPDIR\xprof_&MONSQLID..html

@@xprof ALL ACTIVE SQL_ID "'&MONSQLID'"

spool off
host &_START &_TEMPDIR\xprof_&MONSQLID..html
-------------------------
alter session set nls_numeric_characters='&nls_num_chars';
undef nls_num_chars;
-------------------------
undef MONSQLID
@inc/input_vars_undef