col sqlmon for a200
select dbms_sqltune.report_sql_monitor(sql_id => '&sql_id') sqlmon from dual;
