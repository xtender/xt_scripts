prompt &_C_REVERSE *** Find procedures from ASH by sid &_C_RESET
prompt Usage: @ash/procs_by_sid sid serial# [minutes_ago]
@inc/input_vars_init;

col owner            format a30;
col procedure_name   format a30;
col top_level_sql_id format a13;
col object_name      format a30;
col text             format a120 word;
with 
 obj_list as
(
   select 
            h.PLSQL_ENTRY_OBJECT_ID,h.PLSQL_ENTRY_SUBPROGRAM_ID
           ,h.PLSQL_OBJECT_ID      ,h.PLSQL_SUBPROGRAM_ID
   from v$active_session_history h
   where 
       h.session_id = &1
   and h.session_serial#='&2'
   and ('&3' is null or h.sample_time>systimestamp-interval '0&3' minute)
)
,objects as 
(
   select *
   from obj_list
   unpivot(
           (obj,subobj)    for obj_code    in ( (PLSQL_ENTRY_OBJECT_ID    ,PLSQL_ENTRY_SUBPROGRAM_ID) as 'entry'
                                              , (PLSQL_OBJECT_ID,PLSQL_SUBPROGRAM_ID )                as 'main'
                                              )
          )
)
,agg as (
         select
            obj_code,obj,subobj,count(*) cnt
         from objects 
         group by obj_code,obj,subobj
         order by cnt desc
)
select
    agg.obj_code
   ,agg.obj
   ,agg.subobj
   ,p.OBJECT_TYPE
   ,p.owner,p.OBJECT_NAME,p.PROCEDURE_NAME
   ,agg.cnt
from agg
    ,dba_procedures p
where agg.obj  = p.OBJECT_ID
and agg.subobj = p.SUBPROGRAM_ID
/
with top_level_calls as (
   select h.TOP_LEVEL_SQL_ID,count(*) cnt
   from v$active_session_history h
   where 
       h.session_id = &1
   and h.session_serial#='&2'
   and ('&3' is null or h.sample_time>systimestamp-interval '0&3' minute)
   group by h.TOP_LEVEL_SQL_ID
)
select 
   c.TOP_LEVEL_SQL_ID
  ,c.cnt
  ,to_char(substr(a.sql_fulltext,1,4000)) text
from top_level_calls c
    ,v$sqlarea a
where c.TOP_LEVEL_SQL_ID=a.sql_id
order by 
         cnt desc
       , top_level_sql_id;

col owner            clear;
col procedure_name   clear;
col top_level_sql_id clear;
col object_name      clear;
col text             clear;
@inc/input_vars_undef;