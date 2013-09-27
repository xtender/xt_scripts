@inc/input_vars_init.sql;
set lines 150
select * from table(dbms_xplan.display(null,null,'&1'));
@inc/input_vars_undef.sql;