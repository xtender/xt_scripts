with 
 awr_seg_stat as (
   select
      ts#,obj#,dataobj# 
     ,snap_id
     ,space_used_total
     ,space_used_delta
     ,space_allocated_total
     ,space_allocated_delta
     ,physical_writes_delta
     ,physical_write_requests_delta
   from dba_hist_seg_stat s
   --where obj# in (select object_id from dba_objects where owner='')
)
,top_segs_by_growth as (
   select *
   from (
      select
         ts#,obj#
        ,sum(space_allocated_delta) delta
        ,dense_rank()over(order by sum(space_allocated_delta) desc) N
      from awr_seg_stat
      group by ts#,obj#
   )
   where N<=10 -- topN
)
select
   s.n
  ,o.owner,o.object_type,o.object_name
  ,round(s.delta/1024/1024) "Delta(MB)"
from top_segs_by_growth s
    ,dba_objects o
where s.obj# = o.object_id
order by 1
/
