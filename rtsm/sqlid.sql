col sqlmon format a240;
select dbms_sqltune.report_sql_monitor(sql_id => '&1',report_level => 'ALL',type => 'TEXT') sqlmon from dual;
col sqlmon clear;
undef 1;