@inc/input_vars_init.sql
accept snap_interval prompt "Enter snap_interval in seconds[10]: " default 10;
@tpt/snapper ash,ash1=plsql_object_id+plsql_subprogram_id+sql_id,ash2=sid+user+event+wait_class &snap_interval 1 all
@inc/input_vars_undef.sql
