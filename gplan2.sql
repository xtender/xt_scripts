col inst_id heading inst format 99
col child_number heading CH format 999
break on inst_id on child_number on plan_hash_value skip 1

select 
    g.inst_id
   ,g.child_number
   --,g.plan_hash_value
   ,xpl.*
from
    gv$sql g
   ,table(dbms_xplan.display('gv$sql_plan_statistics_all'
                            ,null
                            ,'advanced'
                            ,'inst_id='          || g.inst_id 
                          ||' and sql_id='''     || g.sql_id || ''''
                          ||' and child_number=' || g.child_number
                            )
         ) xpl
where
    sql_id='&1'
/
clear break