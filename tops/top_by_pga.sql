break on sid on spid on pid on total_allocated skip 1;

select sid,spid,pid,total_allocated,category,allocated,used,max_allocated
from (
    select 
         dense_rank()over(ORDER BY total_allocated desc) rnk
        ,v.* 
    from 
        (
              SELECT
                  s.sid,p.spid,p.pid
                  ,sum(pm.allocated) over(partition by sid) total_allocated
                  ,pm.category
                  ,pm.allocated
                  ,pm.used
                  ,pm.max_allocated
              FROM 
                  v$session s
                , v$process p
                , v$process_memory pm
              WHERE
                  s.paddr = p.addr
              AND p.pid = pm.pid
              ORDER BY total_allocated desc,allocated desc,used desc
        ) v
    )
where rnk<=5
/
clear break;