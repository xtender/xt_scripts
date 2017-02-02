col name    for a30;
col param   for a20;
col spparam for a20;
select 
  p.name
 ,p.display_value  as param
 ,sp.display_value as spparam
 ,sp.ISSPECIFIED
from v$parameter p, v$spparameter sp
where p.name=sp.name
and p.name in (
 'memory_max_target'
,'memory_target'
,'sga_max_size'
,'sga_target'
,'shared_pool_size'
,'db_cache_size'
,'db_keep_cache_size'
,'result_cache_max_size'
,'inmemory_size'
,'pga_aggregate_target'
)
order by decode(p.name
,'memory_max_target'     ,10
,'memory_target'         ,11
,'sga_max_size'          ,20
,'sga_target'            ,21
,'shared_pool_size'      ,30
,'db_cache_size'         ,31
,'db_keep_cache_size'    ,32
,'result_cache_max_size' ,40
,'inmemory_size'         ,50
,'pga_aggregate_target'  ,100
)
/
col name    clear;
col param   clear;
col spparam clear;