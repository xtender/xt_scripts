@inc/input_vars_init.sql
col 1 new_val 1 noprint
select nvl('&1',10) "1" from dual;
@tpt/snapper ash,ash1=plsql_object_id+plsql_subprogram_id+sql_id,ash2=sid+user+event+wait_class &1 1 all
@inc/input_vars_undef.sql
