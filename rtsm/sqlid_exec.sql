prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SQL_ID='&1'....

@sqlplus_store
set termout off timing off ver off feed off head off lines 10000000 pagesize 0

define MON_SQLID   =&1
define MON_SQLEXEC =&2
spool &_TEMPDIR\xprof_&MONSQLID..html

SELECT
	DBMS_SQLTUNE.REPORT_SQL_MONITOR( 
       SQL_ID       => '&MON_SQLID',
       sql_exec_id  => '&MON_SQLEXEC',
       report_level => 'ALL',
       type         => 'ACTIVE') as report   
FROM dual
/
spool off
host &_START &_TEMPDIR\xprof_&MONSQLID..html
@sqlplus_restore