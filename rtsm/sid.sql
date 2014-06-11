prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SID &1.... (11.2+)
@inc/input_vars_init;
set termout off timing off ver off feed off head off lines 10000000 pagesize 0

-- workaround for bug with:
-- ORA-06502: PL/SQL: numeric or value error
-- ORA-06512: at "SYS.DBMS_SQLTUNE", line 14265
set termout off;
col nls_num_chars new_val nls_num_chars noprint;
select value nls_num_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
alter session set nls_numeric_characters='.,';


define MONSID=&1
spool &_TEMPDIR\xprof_&MONSID..html

@@xprof ALL ACTIVE SESSION_ID &MONSID

spool off

host &_START &_TEMPDIR\xprof_&MONSID..html

-- restore all:
alter session set nls_numeric_characters='&nls_num_chars';
undef 1 nls_num_chars;

set termout on;
@inc/input_vars_undef;