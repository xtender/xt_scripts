with 
 current_size as (
   select sum(bytes) bytes from dba_segments where rownum>0
)
,total_allocs as (
   select
     s.snap_id
    ,sum(space_allocated_delta) total_space_allocated_delta
   from dba_hist_seg_stat s
   group by snap_id
   having sum(space_allocated_total) <> 0
)
,allocation_history as (
   select
     snap_id
    ,total_space_allocated_delta as delta
    ,sum(total_space_allocated_delta) over ( order by snap_id) as rolling_delta
    ,sum(total_space_allocated_delta) over() as total_delta
   from total_allocs t
)
select
  s.snap_id
 ,to_char(end_interval_time,'yyyy-mm-dd hh24:mi')           snap_time
 ,round(a.delta/1024/1024)                                  "DELTA(MB)"
 ,round((c.bytes-a.total_delta+a.rolling_delta)/1024/1024)  "SIZE(MB)"
 ,c.bytes/1024/1024                                         "CURRENT_SIZE(MB)"
from dba_hist_snapshot s
    ,current_size c
    ,allocation_history a
where s.snap_id=a.snap_id
order by s.snap_id
/
