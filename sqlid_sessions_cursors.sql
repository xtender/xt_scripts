col username   format a30;
col osuser     format a30;
col program    format a30;
col pe_object  format a35;
col po_object  format a35;

col status     format a20;
col wait_class format a20;

select
     c.sid
    ,s.username
    ,s.osuser
    ,s.program
    ,s.status
    ,s.wait_class
    ,nvl2( pe.owner
          ,pe.owner
           ||'.'||pe.OBJECT_NAME
           ||nvl2(pe.PROCEDURE_NAME,'.'||pe.PROCEDURE_NAME,'')
          ,''
         )                                        as pe_object
    ,nvl2( po.owner
          ,po.owner
           ||'.'||po.OBJECT_NAME
           ||nvl2(po.PROCEDURE_NAME,'.'||po.PROCEDURE_NAME,'')
          ,null
         )                                        as po_object
from 
     v$open_cursor c
    ,v$session s
    ,dba_procedures pe
    ,dba_procedures po
where 
     c.sql_id               = '&1'
 and c.sid                  = s.sid
-- and s.status               = 'ACTIVE' 
-- and s.wait_class          != 'Idle'
 and pe.OBJECT_ID    (+)    = s.PLSQL_ENTRY_OBJECT_ID
 and pe.SUBPROGRAM_ID(+)    = s.PLSQL_ENTRY_SUBPROGRAM_ID
 and po.OBJECT_ID    (+)    = s.PLSQL_OBJECT_ID
 and po.SUBPROGRAM_ID(+)    = s.PLSQL_SUBPROGRAM_ID
order by decode(s.osuser,'oracle',2,1)
        ,s.osuser
        ,s.username
/
