prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SQL_ID='&1' and EXEC_ID='&2'....

@inc/input_vars_init;
set termout off timing off ver off feed off head off lines 32767 pagesize 0
-------------------------
-- workaround for bug with:
-- ORA-06502: PL/SQL: numeric or value error
-- ORA-06512: at "SYS.DBMS_SQLTUNE", line 14265
col nls_num_chars new_val nls_num_chars noprint;
select value nls_num_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
alter session set nls_numeric_characters='.,';
-------------------------
define MON_SQLID   ="&1"
define MON_SQLEXEC ="&2"
define MON_FILE=&_TEMPDIR\xprof_&MON_SQLID._&MON_SQLEXEC..html
spool &MON_FILE

SELECT
	DBMS_SQLTUNE.REPORT_SQL_MONITOR( 
       SQL_ID       => '&MON_SQLID',
       sql_exec_id  => '&MON_SQLEXEC',
       report_level => 'ALL',
       type         => 'ACTIVE') as report   
FROM dual
/
spool off
host &_START &MON_FILE
-------------------------
alter session set nls_numeric_characters='&nls_num_chars';
undef nls_num_chars;
-------------------------
undef MON_FILE MON_SQLID MON_SQLEXEC
@inc/input_vars_undef;