@inc/input_vars_init;
prompt *** &_C_REVERSE Find queries by TOP_SQL_ID. &_C_RESET
prompt * Usage: @sql_by_top_sqlid [top_sql_id]
col sql_text     format a80;
with 
s as (
      select distinct
           h.sql_id
          ,h.sql_child_number
          ,h.top_level_sql_id
      from v$active_session_history h
      where 
           top_level_sql_id='&1'
       and sql_id !='&1'
)
select s.top_level_sql_id                                              as top_sqlid
      ,s.sql_id
      ,s.sql_child_number
      ,ch.sql_id                                                       as curr_sqlid
      ,ch.sql_text
      ,decode(ch.executions ,0,0,  ch.elapsed_time/1e6/ch.executions)  as elaexe
      ,ch.executions                                                   as cnt
      ,ch.elapsed_time                                                 as overall_ela
from s
    ,v$sqlarea ch
where ch.sql_id  = s.sql_id 
order by overall_ela desc
;

col sql_text     clear;
@inc/input_vars_undef;
