prompt #####################################################
prompt #  DBMS_SQLTUNE.REPORT_SQL_DETAIL
prompt #####################################################

store set sqlplus_settings.sql replace;

accept MONSQLID prompt "SQL_ID: ";

set termout off timing off ver off feed off head off lines 10000000 pagesize 0
-------------------------
spool xprof_d_&MONSQLID..html
----------------------
-- workaround for bug with:
-- ORA-06502: PL/SQL: numeric or value error
-- ORA-06512: at "SYS.DBMS_SQLTUNE", line 14265
col nls_num_chars new_val nls_num_chars noprint;
select value nls_num_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
alter session set nls_numeric_characters='.,';
----------------------
spool xprof_d_&MONSQLID..html

SELECT
	DBMS_SQLTUNE.REPORT_SQL_DETAIL(   
		 SQL_ID       => '&MONSQLID'
		,report_level => 'ALL'
		,type         => 'ACTIVE'
	) as report   
FROM dual
/
spool off

-- restore all:
set termout off;
alter session set nls_numeric_characters='&nls_num_chars';
col sqlmon clear;
undef nls_num_chars;
@sqlplus_settings;
set termout on;
----------------------
prompt #####################################################
prompt #  Report file: xprof_d_&MONSQLID..html
-------------------------
undef MONSQLID