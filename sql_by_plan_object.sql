col operation for a50;

select * 
from (
    select 
         p.sql_id
        ,p.plan_hash_value
        ,p.operation
        ,s.elapsed_time/1e6/nullif(s.executions,0) as elaexe
        ,s.executions
    from
        (select distinct 
             p.sql_id
            ,p.plan_hash_value
            ,p.child_number
            ,operation||' '||options as operation 
         from v$sql_plan p 
         where p.object_name=upper('&1')
        ) p
        ,v$sql s
    where 
          s.sql_id          = p.sql_id
      and s.plan_hash_value = p.plan_hash_value 
      and s.child_number    = p.child_number
    order by elapsed_time desc, elaexe desc, executions desc
    )
where rownum<30
/
col operation clear;