select 
   pool, 
   name, 
   round(bytes/1024/1024,2) mbytes 
from v$sgastat where pool is null
union all
select 
   pool,
   'summary', 
   round(sum(bytes)/1024/1024,2)
from v$sgastat 
where pool is not null
group by pool
order by 1 nulls first, 2 desc;

COLUMN pool    HEADING "Pool"
COLUMN name    HEADING "Name"
COLUMN sgasize HEADING "Allocated" FORMAT 999,999,999,999
COLUMN bytes   HEADING "Free" FORMAT 999,999,999,999

SELECT
    f.pool
  , f.name
  , s.sgasize
  , f.bytes
  , ROUND(f.bytes/s.sgasize*100, 2) "% Free"
FROM
    (SELECT SUM(bytes) sgasize, pool FROM v$sgastat GROUP BY pool) s
  , v$sgastat f
WHERE
    f.name = 'free memory'
  AND f.pool = s.pool
/
COLUMN pool    clear;
COLUMN name    clear;
COLUMN sgasize clear;
COLUMN bytes   clear;