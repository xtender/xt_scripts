prompt &_C_RED Running DBMS_SQLTUNE.report_sql_monitor_list for sid or sql_id.... &_C_RESET;

@inc/input_vars_init;

-------------------------------------------------------
-- workaround for bug with:
-- ORA-06502: PL/SQL: numeric or value error
-- ORA-06512: at "SYS.DBMS_SQLTUNE", line 14265
set termout off;
col nls_num_chars new_val nls_num_chars noprint;
select value nls_num_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
alter session set nls_numeric_characters='.,';
set termout on;
-------------------------------------------------------

set termout off timing off ver off feed off head off lines 10000000 pagesize 0

var res clob;
define MONSQLID=&1

declare
   v_param varchar2(100):=q'[&1]';
   v_check int;
   v_res clob;
begin
   if length(v_param)=13 then 
      select count(*) into v_check from v$sqlarea a where a.sql_id=v_param and rownum=1;
   end if;
   if v_check = 1 then
       v_res:=dbms_sqltune.report_sql_monitor_list(
                 sql_id       => v_param
                ,report_level => 'ALL'
                ,type         => 'HTML'
                ,base_path    => 'file:///S:/rtsm/base_path/'
                );
   elsif regexp_replace(v_param,'\D')=v_param then
       v_res:=dbms_sqltune.report_sql_monitor_list(
                 session_id   => v_param
                ,report_level => 'ALL'
                ,type         => 'HTML'
                ,base_path    => 'file:///S:/rtsm/base_path/'
                );
   else
      v_res:='Error: Parameter must be sid or sql_id!';
   end if;
   :res := v_res;
end;
/
spool &_TEMPDIR\xprof_&MONSQLID..html
print res;
spool off
host &_START &_TEMPDIR\xprof_&MONSQLID..html

-------------------------------------------------------
-- restore all:
set termout off;
alter session set nls_numeric_characters='&nls_num_chars';
undef nls_num_chars;
set termout on;
-------------------------
undef MONSQLID
@inc/input_vars_undef