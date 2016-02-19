@@show_window_intervals;

accept MON_INTERVAL prompt "MON_INTERVAL: ";
accept TUE_INTERVAL prompt "TUE_INTERVAL: ";
accept WED_INTERVAL prompt "WED_INTERVAL: ";
accept THU_INTERVAL prompt "THU_INTERVAL: ";
accept FRI_INTERVAL prompt "FRI_INTERVAL: ";
accept SAT_INTERVAL prompt "SAT_INTERVAL: ";
accept SUN_INTERVAL prompt "SUN_INTERVAL: ";

begin
 DBMS_SCHEDULER.SET_ATTRIBUTE(  rtrim('MONDAY_WINDOW   '), 'repeat_interval', '&MON_INTERVAL');
 DBMS_SCHEDULER.SET_ATTRIBUTE(  rtrim('TUESDAY_WINDOW  '), 'repeat_interval', '&TUE_INTERVAL');
 DBMS_SCHEDULER.SET_ATTRIBUTE(  rtrim('WEDNESDAY_WINDOW'), 'repeat_interval', '&WED_INTERVAL');
 DBMS_SCHEDULER.SET_ATTRIBUTE(  rtrim('THURSDAY_WINDOW '), 'repeat_interval', '&THU_INTERVAL');
 DBMS_SCHEDULER.SET_ATTRIBUTE(  rtrim('FRIDAY_WINDOW   '), 'repeat_interval', '&FRI_INTERVAL');
 DBMS_SCHEDULER.SET_ATTRIBUTE(  rtrim('SATURDAY_WINDOW '), 'repeat_interval', '&SAT_INTERVAL');
 DBMS_SCHEDULER.SET_ATTRIBUTE(  rtrim('SUNDAY_WINDOW   '), 'repeat_interval', '&SUN_INTERVAL');
end;
/
@@show_window_intervals;
