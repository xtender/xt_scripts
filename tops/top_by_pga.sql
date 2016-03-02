select * 
from (
      SELECT
          s.sid,p.spid
          ,sum(pm.allocated) over(partition by sid) total_allocated
          ,pm.*
      FROM 
          v$session s
        , v$process p
        , v$process_memory pm
      WHERE
          s.paddr = p.addr
      AND p.pid = pm.pid
      ORDER BY
          3 desc
)
where rownum<=10
/
