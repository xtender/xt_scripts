prompt &_C_REVERSE *** Find procedures by list of sql_id'select &_C_RESET
prompt _________________________________________________________
accept sqlids prompt 'Enter list of sql_id: ';
col owner           format a30;
col procedure_name  format a30;
with 
sqlids as (
   select
      regexp_substr(q'[&sqlids]','\w{13}',1,level) sqlid
   from dual
   connect by regexp_substr(q'[&sqlids]','\w{13}',1,level) is not null
)
,obj_list as
(
   select 
            h.PLSQL_ENTRY_OBJECT_ID,h.PLSQL_ENTRY_SUBPROGRAM_ID
           ,h.PLSQL_OBJECT_ID      ,h.PLSQL_SUBPROGRAM_ID
   from v$active_session_history h
   where 
       h.sql_id in (select sqlids.sqlid from sqlids)
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
col owner           clear;
col procedure_name  clear;