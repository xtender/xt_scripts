select *
from (
  select 
     h.sql_id
    ,count(distinct sql_plan_hash_value) plans_cnt
    ,min(sql_plan_hash_value)            phv_min
    ,max(sql_plan_hash_value)            phv_max
    ,count(distinct sql_exec_id)         execs
    ,count(*)                            cnt
  from v$active_session_history h
  where sql_id is not null
  group by sql_id
  order by cnt desc
)
where rownum<=20
/
