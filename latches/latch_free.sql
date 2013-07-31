with latch_free as (
   select p2 
   from v$session_wait_history
   where event = 'latch free' 
)
select l.latch#,l.name,count(*) 
from latch_free lf
    ,v$latch l
where latch# =lf.p2
group by l.latch#,l.name;
/
select *
from v$result_cache_statistics rcs
/
select * 
from v$result_cache_objects o
order by o.pin
/
select o.name,count(*)
from v$result_cache_objects o
group by o.name
order by 2 desc
/
select * from v$latch_parent where name like 'Result Cache: RC Latch';
