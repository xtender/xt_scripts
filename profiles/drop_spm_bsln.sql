accept _sql_handle prompt "SQL Handle: ";
accept _plan_name  prompt "Plan name[default-all]: ";
set serverout on;
declare
   res pls_integer;
begin
   res := dbms_spm.drop_sql_plan_baseline(
              sql_handle => '&_sql_handle'
            , plan_name  => '&_plan_name'
         );
   dbms_output.put_line(res||' plans dropped');
end;
/
set serverout off;
undef _sql_handle;
undef _plan_name;
