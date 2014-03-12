col event format a50;
select eh.*
      ,to_char(
              100*sum(wait_count)over(order by wait_time_milli)
                / sum(wait_count)over()
             ,'999.90') running_pct
from v$event_histogram eh
where upper(eh.EVENT) like upper('%&1%')
order by 1,2,3;
col event clear;
