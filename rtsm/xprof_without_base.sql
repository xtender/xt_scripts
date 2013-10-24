--prompt Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SID &3....

-- workaround for bug with:
-- ORA-06502: PL/SQL: numeric or value error
-- ORA-06512: at "SYS.DBMS_SQLTUNE", line 14265
set termout off;
col nls_num_chars new_val nls_num_chars noprint;
select value nls_num_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
alter session set nls_numeric_characters='.,';
set termout on;


SELECT
	DBMS_SQLTUNE.REPORT_SQL_MONITOR(   
		&3=>&4
		,report_level=>'&1'
		,type => '&2'
		--,base_path    => 'file:///S:/rtsm/base_path/'
	) as report   
FROM dual
/

-- restore all:
set termout off;
alter session set nls_numeric_characters='&nls_num_chars';
col sqlmon clear;
undef nls_num_chars;

set termout on;