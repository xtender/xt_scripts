@inc/input_vars_init;
col sql_text       format a80;
col text           format a80;
col procedure_name format a30;
with p as (
      select owner
            ,object_name
            ,procedure_name
            ,object_type
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
      select 
           p.*
          ,h.*
      from p
          ,v$sqlarea h
      where 
           h.program_id = p.object_id
)
select
       s.owner
      ,s.object_name
      ,s.procedure_name
      ,s.object_id
      ,s.subprogram_id
      ,s.sql_id
      ,s.sql_text
      ,decode(s.executions ,0,0,  s.elapsed_time/1e6/s.executions) as elaexe
      ,s.executions                                                as cnt
      ,ss.owner
      ,ss.name
      ,ss.TYPE
      ,ss.line
      ,ss.TEXT
from s
    ,dba_source ss
where 
      ss.owner = s.owner
  and ss.name  = s.object_name
  and ss.type  = s.object_type
  and ss.line >= s.program_line# 
  and ss.line  < s.program_line#+5 ;

col sql_text       clear;
col text           clear;
col procedure_name clear;
@inc/input_vars_undef;
