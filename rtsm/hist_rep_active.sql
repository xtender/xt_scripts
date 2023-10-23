@inc/input_vars_init;
define MON_FILE=&_TEMPDIR/rtsm_hist_rep_&1..html

prompt * Saving to &MON_FILE

set termout off timing off ver off feed off head off lines 32767 pagesize 0
spool &MON_FILE
select dbms_auto_report.report_repository_detail(rid => &1, type => 'active') from dual;
spool off;
host &_START &MON_FILE

@inc/input_vars_undef;