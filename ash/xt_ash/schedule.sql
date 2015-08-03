set feed on;
accept _time_beg prompt "Start timestamp[yyyy-mm-dd hh24:mi:ss TZR]: ";
accept _time_end prompt "End   timestamp[yyyy-mm-dd hh24:mi:ss TZR]: ";
exec xt_ash.schedule(timestamp'&_time_beg',timestamp'&_time_end');
@@check_status;
@@check_schedule;
@inc/input_vars_undef;