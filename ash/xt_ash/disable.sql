set feed on;
exec xt_ash.disable;
exec xt_ash.drop_job;
@@check_status;
@@check_schedule;
@inc/input_vars_undef;