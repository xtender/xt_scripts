prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SQL_ID &1....
@inc/input_vars_init;
set timing off ver off feed off head off lines 10000000 pagesize 0
-------------------------
set termout off;
-- workaround for bug with:
-- ORA-06502: PL/SQL: numeric or value error
-- ORA-06512: at "SYS.DBMS_SQLTUNE", line 14265
col nls_num_chars new_val nls_num_chars noprint;
select value nls_num_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
alter session set nls_numeric_characters='.,';
set termout on;
-------------------------

@@xprof ALL TEXT SQL_ID "'&1'"

-------------------------
-- restore all:
alter session set nls_numeric_characters='&nls_num_chars';
undef 1 nls_num_chars;
-------------------------
@inc/input_vars_undef;