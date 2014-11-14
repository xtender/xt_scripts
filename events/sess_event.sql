prompt;
prompt &_C_RED *** v$session_event by sid &_C_RESET;
prompt * Usage @events/sess_event SID
prompt;
col wait_class for a30;
col event      for a64;
col TIME_WAITED_MICRO for 999G999G999999;
col sum_class noprint;
break on sid on wait_class skip page;
select 
     se.sid
    ,se.wait_class
    ,se.event
    ,se.TOTAL_WAITS
    ,se.TOTAL_TIMEOUTS
    ,se.TIME_WAITED
    ,se.TIME_WAITED_MICRO
    ,se.AVERAGE_WAIT
    ,se.MAX_WAIT
    ,sum(TIME_WAITED_MICRO) over(partition by wait_class) sum_class
from v$session_event se
where sid=&1
order by WAIT_CLASS_ID, TIME_WAITED_MICRO
/
col wait_class clear;
col event      clear;
col TIME_WAITED_MICRO clear;
col sum_class         clear;
clear break
