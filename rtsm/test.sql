set termout off timing off ver off feed off head off lines 10000000 pagesize 0 trimspool on
spool rtsm_&1..html
SELECT
   DBMS_SQLTUNE.REPORT_SQL_MONITOR(   
       sql_id       => '&1'
      ,report_level =>'ALL'
      ,type         => 'ACTIVE'
      ,base_path    => 'file:///S:/rtsm/base_path/'
   ) as report   
FROM dual
/
spool off
