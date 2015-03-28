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