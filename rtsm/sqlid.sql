@inc/input_vars_init;
col sqlmon format a300;

-- workaround for bug with:
-- ORA-06502: PL/SQL: numeric or value error
-- ORA-06512: at "SYS.DBMS_SQLTUNE", line 14265
set termout off;
col nls_num_chars new_val nls_num_chars noprint;
select value nls_num_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
alter session set nls_numeric_characters='.,';


-- main part:
set termout on;
select/*+ no_monitor */ dbms_sqltune.report_sql_monitor(sql_id => '&1',report_level => 'ALL',type => 'TEXT') sqlmon from dual;
set termout off
-- end main part


-- restore all:
alter session set nls_numeric_characters='&nls_num_chars';
col sqlmon clear;
undef 1 nls_num_chars;

set termout on;
@inc/input_vars_undef;