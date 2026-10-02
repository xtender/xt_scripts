prompt ***;
prompt Drop SQL Patch;
prompt ***;

set feed on;

accept p_name       prompt "Patch name: ";

begin
   dbms_sqldiag.drop_sql_patch(q'[&p_name]');
end;
/
undef p_name;
