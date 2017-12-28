col pid new_val pid
SELECT
    s.sid,p.spid
    ,sum(pm.allocated) over(partition by sid) total_allocated
    ,cast(pm.PID as varchar2(6)) PID
    ,pm.serial#
    ,pm.CATEGORY
    ,pm.ALLOCATED
    ,pm.USED
    ,pm.MAX_ALLOCATED
FROM
    v$session s
  , v$process p
  , v$process_memory pm
WHERE
    s.paddr = p.addr
AND p.pid = pm.pid
and s.sid = &1
ORDER BY ALLOCATED desc;

ORADEBUG SETMYPID;
ORADEBUG DUMP PGA_DETAIL_GET &pid 1;

SELECT * FROM v$process_memory_detail ORDER BY pid, bytes DESC;

undef pid;
