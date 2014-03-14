col event               format a50;
col overall_chart       format a20;
col LAST_UPDATE_TIME    format a34;
break on event# on event skip 1 page;

with evh as (
    select eh.*
          ,sum(wait_count)over(partition by EVENT#,EVENT order by wait_time_milli)  as running_sum
          ,sum(wait_count)over(partition by EVENT#,EVENT)                           as overall_sum
          
    from v$event_histogram eh
    where upper(eh.EVENT) like upper('%&1%')
    )
select evh.* 
      ,to_char(100*running_sum / overall_sum, '999.90')  as running_pct
      ,to_char(100*wait_count  / overall_sum, '999.90')  as overall_pct
      ,rpad('#',ceil(wait_count*20/overall_sum),'#')     as overall_chart
from evh
order by 1,2,3;
col event               clear;
col overall_chart       clear;
col LAST_UPDATE_TIME    clear;
clear break;