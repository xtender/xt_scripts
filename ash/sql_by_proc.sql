@inc/input_vars_init;
prompt *** &_C_REVERSE Find queries by procedure_name. &_C_RESET
prompt * Usage: @sql_by_proc object_mask [owner_mask]
col sql_text     format a80;
col top_sql_text format a80;
with p as (
      select owner
            ,object_name
            ,procedure_name
            ,object_id
            ,subprogram_id
      from dba_procedures
      where
            owner like nvl('&2','%')
       and (
            object_name    like upper('&1') 
            or 
            procedure_name like upper('&1')
           )
),s as (
      select distinct
           h.sql_id
          ,h.sql_child_number
          ,h.top_level_sql_id
      from p
          ,v$active_session_history h
      where 
         (
           (h.plsql_entry_object_id = p.object_id and h.plsql_entry_subprogram_id = p.subprogram_id)
           or
           (h.plsql_object_id       = p.object_id and h.plsql_subprogram_id = p.subprogram_id)
         )
)
select s.sql_id
      ,s.sql_child_number
      ,ch.sql_text
      ,decode(ch.executions ,0,0,  ch.elapsed_time/1e6/ch.executions) as elaexe
      ,ch.executions                                                  as cnt
      ,s.top_level_sql_id                                             as top_sqlid
      ,top.sql_text                                                   as top_sql_text
      ,decode(top.executions,0,0, top.elapsed_time/1e6/ch.executions) as top_elaexe
      ,top.executions                                                 as top_cnt
from s
    ,v$sqlarea ch
    ,v$sqlarea top
where ch.sql_id  = s.sql_id 
  and top.sql_id = s.top_level_sql_id;

col sql_text     clear;
col top_sql_text clear;
@inc/input_vars_undef;
