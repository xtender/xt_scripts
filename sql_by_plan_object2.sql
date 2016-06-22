col sql_id for a13;
col child_cursors for a50
--col plan_hv
--col execs
--col elaexe
with 
  sqls as (
      select distinct sql_id
      from v$sql_plan p
      where p.object_owner = '&OWNER'
        and p.object_name = '&OBJECT_NAME'
  )
select s.sql_id
      ,listagg(s.child_number,',') within group(order by child_number) as child_cursors
      ,s.plan_hash_value                                               as plan_hv
      ,sum(s.executions)                                               as execs
      ,sum(s.elapsed_time)/1e6/sum(nullif(s.executions,0))             as elaexe
from sqls,
     v$sql s
where sqls.sql_id = s.sql_id
group by s.sql_id,s.plan_hash_value
order by 1,2
/
