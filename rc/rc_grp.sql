select 
   name
  ,status
  ,count(*)
from v$result_cache_objects co
where --co.TYPE='Result'
  co.name like '%&1%'
group by name,status
order by 1,2
/
