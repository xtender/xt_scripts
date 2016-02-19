col window_name      for a18;
col repeat_interval  for a60;
col duration         for a15;

select w.WINDOW_NAME,w.REPEAT_INTERVAL,w.duration
from dba_scheduler_windows w
where w.WINDOW_NAME in ( rtrim('MONDAY_WINDOW   ')
                        ,rtrim('TUESDAY_WINDOW  ')
                        ,rtrim('WEDNESDAY_WINDOW')
                        ,rtrim('THURSDAY_WINDOW ')
                        ,rtrim('FRIDAY_WINDOW   ')
                        ,rtrim('SATURDAY_WINDOW ')
                        ,rtrim('SUNDAY_WINDOW   ')
                       )
order by decode ( window_name
                        ,rtrim('MONDAY_WINDOW   '),1
                        ,rtrim('TUESDAY_WINDOW  '),2
                        ,rtrim('WEDNESDAY_WINDOW'),3
                        ,rtrim('THURSDAY_WINDOW '),4
                        ,rtrim('FRIDAY_WINDOW   '),5
                        ,rtrim('SATURDAY_WINDOW '),6
                        ,rtrim('SUNDAY_WINDOW   '),7
                       )
/                       
col window_name      clear;
col repeat_interval  clear;
col duration         clear;
