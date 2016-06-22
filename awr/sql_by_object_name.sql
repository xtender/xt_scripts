set feed on;
col sql_id        for a13;
col child_cursors for a50;
--col plan_hv
--col execs
--col elaexe
with 
  sqls as (
      select distinct sql_id
      from dba_hist_sql_plan p
      where p.object_owner = '&OWNER'
        and p.object_name = '&OBJECT_NAME'
  )
select s.sql_id
      ,s.plan_hash_value                                               as plan_hv
      ,sum(s.executions_delta)                                         as execs
      ,sum(s.elapsed_time_delta)/1e6/sum(nullif(s.executions_delta,0)) as elaexe
from sqls,
     dba_hist_sqlstat s
where sqls.sql_id = s.sql_id
group by s.sql_id,s.plan_hash_value
order by 1,2
/
