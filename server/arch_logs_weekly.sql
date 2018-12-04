with agg_by_day  as (
   select 
          trunc(trunc(first_time),'iw') week_start_date,
         -- trunc(first_time) dd,
          to_char(trunc(first_time),'DY') week_day,
          round(sum(blocks*block_size)/1024/1024/1024,1) size_gb
   from v$archived_log l 
   where first_time>trunc(sysdate)-30
     and dest_id=1
   group by trunc(first_time) 
   order by 1 desc, 2 desc
)
select *
from agg_by_day
pivot(
  sum(size_gb) AS sum_dd
   FOR (week_day) IN ('MON' as mon
                     ,'TUE' as TUE
                     ,'WED' as WED
                     ,'THU' as THU
                     ,'FRI' as FRI
                     ,'SAT' as SAT
                     ,'SUN' as SUN
                     )
)
order by 1;
