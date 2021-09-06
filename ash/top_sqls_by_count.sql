col stext for a100 trunc;
select 
   ash.*
  ,substr(s.sql_text,1,200) stext
  ,s.elapsed_time/nullif(executions,0)/1e6 as elaexe
  ,s.executions
  ,to_char(s.elapsed_time,'tm9') elapsed_time
from (
  select 
     row_number()over(order by count(*) desc) rn
    ,h.sql_id
    ,count(distinct sql_plan_hash_value) plans_cnt
    ,min(sql_plan_hash_value)            phv_min
    ,max(sql_plan_hash_value)            phv_max
    ,count(distinct sql_exec_id)         ash_execs
    ,count(*)                            ash_cnt
  from v$active_session_history h
  where sql_id is not null
  group by sql_id
) ash
   left join v$sqlarea s
      on s.sql_id = ash.sql_id
where rn<=20

/
