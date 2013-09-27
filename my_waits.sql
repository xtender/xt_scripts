col wait_class  format a30;
col event       format a50;
col time_waited_micro format a20;
SELECT
                        wait_class
                       ,event
                       ,total_waits
                       ,total_timeouts
                       ,time_waited
                       ,average_wait
                       ,max_wait
&_IF_ORA11_OR_HIGHER   ,lpad(to_char(time_waited_micro,'fm999g999g999g999g990',q'[nls_numeric_characters='. ']'),20) as time_waited_micro
FROM
  v$session_event e 
WHERE E.SID = &my_sid
order by time_waited_micro desc
/
col wait_class  clear;
col event       clear;
