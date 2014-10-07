col name   for a120;
col status for a15;
select * 
from (
   select 
      name
     ,status
     ,count(*) cnt
   from v$result_cache_objects co
   --where co.TYPE='Result'
   group by name,status
   order by cnt desc
)
where rownum<=10;

col name   clear;
col status clear;