prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SQL_ID='&1' and EXEC_ID='&2'....

@inc/input_vars_init;
define MON_SQLID   ="&1"
define MON_SQLEXEC ="&2"
define MON_FILE=&_TEMPDIR\xprof_&MON_SQLID._&MON_SQLEXEC..html
spool &MON_FILE

set termout off timing off ver off feed off head off lines 32767 pagesize 0


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
@inc/input_vars_undef;