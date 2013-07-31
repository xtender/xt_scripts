col type           for a15;
col owner          for a12;
col object_name    for a30;
col procedure_name for a30;
set null "---"
-- handmade "pivot" for all oracle versions:
with t as (
   select
      ash.PLSQL_ENTRY_OBJECT_ID       ple_id
     ,ash.PLSQL_ENTRY_SUBPROGRAM_ID   ple_sid
     ,ash.PLSQL_OBJECT_ID             plo_id
     ,ash.PLSQL_SUBPROGRAM_ID         plo_sid
     ,count(*)                        cnt
   from
      v$active_session_history ash
   where
      ash.sql_id='&1'
   group by 
      ash.PLSQL_ENTRY_OBJECT_ID
     ,ash.PLSQL_ENTRY_SUBPROGRAM_ID
     ,ash.PLSQL_OBJECT_ID
     ,ash.PLSQL_SUBPROGRAM_ID
),
pl_obj as (
   select 
      decode(n,0,'PLSQL Entry ID'  ,'PLSQL Object ID') as type
     ,decode(n,0,ple_id            ,plo_id           ) as pl_id
     ,decode(n,0,ple_sid           ,plo_sid          ) as pl_sid
     ,sum(cnt) cnt
   from t
       ,(select 0 n from dual 
         union all 
         select 1 from dual
        ) t2
   group by 
      decode(n,0,'PLSQL Entry ID'  ,'PLSQL Object ID') 
     ,decode(n,0,ple_id            ,plo_id           )
     ,decode(n,0,ple_sid           ,plo_sid          )
)
select
   'PLSQL Entry ID' as type
  ,p.owner,p.OBJECT_NAME,p.PROCEDURE_NAME
  ,cnt
from 
   pl_obj
  ,dba_procedures p
where p.OBJECT_ID(+)    = pl_obj.pl_id
 and p.SUBPROGRAM_ID(+) = pl_obj.pl_sid
order by cnt desc
;
set null ""
col type           clear;
col owner          clear;
col object_name    clear;
col procedure_name clear;