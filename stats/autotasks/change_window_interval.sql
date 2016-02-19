@@show_window_clients;
exec DBMS_SCHEDULER.SET_ATTRIBUTE( '&WINDOW', 'repeat_interval', '&repeat_interval');
select w.WINDOW_NAME,w.REPEAT_INTERVAL
from dba_scheduler_windows w
where w.WINDOW_NAME = '&WINDOW'
/
