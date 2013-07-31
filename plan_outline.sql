@@inc/input_vars_init.sql
select * from table(dbms_xplan.display_cursor('&1','&2',nvl('&3','all -projection +outline')));
@@inc/input_vars_undef.sql