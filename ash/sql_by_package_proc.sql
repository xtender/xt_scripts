@inc/input_vars_init;
prompt *** &_C_REVERSE Find queries by procedure_name. &_C_RESET

accept _owner  prompt "Owner                  : ";
accept _object prompt "Procedure/Package      : ";
accept _proc   prompt "Procedure(for packages): ";

col TOP_SQLID    for a13;
col SQL_ID       for a13;
col CURR_SQLID   for a13;
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
            owner like nvl(upper('&_owner'),'%')
       and object_name    like upper('&_object')
       and (trim('&_proc') is null or trim('&_proc') is not null and procedure_name like upper('&_proc'))
),s as (
      select distinct
           h.sql_id
          ,h.sql_child_number
&_IF_ORA112_OR_HIGHER          ,h.top_level_sql_id
      from p
          ,v$active_session_history h
      where 
         (
           (h.plsql_entry_object_id = p.object_id and h.plsql_entry_subprogram_id = p.subprogram_id)
           or
           (h.plsql_object_id       = p.object_id and h.plsql_subprogram_id       = p.subprogram_id)
         )
)
select '...'                                                           as type
&_IF_ORA112_OR_HIGHER      ,s.top_level_sql_id                                              as top_sqlid
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
&_IF_ORA112_OR_HIGHER union all
&_IF_ORA112_OR_HIGHER select 'top'                                                           as type
&_IF_ORA112_OR_HIGHER      ,s.top_level_sql_id                                              as top_sqlid
&_IF_ORA112_OR_HIGHER      ,s.sql_id
&_IF_ORA112_OR_HIGHER      ,s.sql_child_number
&_IF_ORA112_OR_HIGHER      ,ch.sql_id                                                       as curr_sqlid
&_IF_ORA112_OR_HIGHER      ,ch.sql_text
&_IF_ORA112_OR_HIGHER      ,decode(ch.executions ,0,0,  ch.elapsed_time/1e6/ch.executions)  as elaexe
&_IF_ORA112_OR_HIGHER      ,ch.executions                                                   as cnt
&_IF_ORA112_OR_HIGHER      ,ch.elapsed_time                                                 as overall_ela
&_IF_ORA112_OR_HIGHER from s
&_IF_ORA112_OR_HIGHER     ,v$sqlarea ch
&_IF_ORA112_OR_HIGHER where ch.sql_id  = s.top_level_sql_id
&_IF_ORA112_OR_HIGHER order by overall_ela desc
;

col TOP_SQLID    clear;
col SQL_ID       clear;
col CURR_SQLID   clear;
col sql_text     clear;
col top_sql_text clear;
@inc/input_vars_undef;
