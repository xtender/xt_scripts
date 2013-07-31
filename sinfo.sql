col ssid             for a12
col username         for a10
col osuser           for a10
col wclass           for a10
col status_event     for a50
col program          for a15
col plsql_entry_obj  for a25
col plsql_obj        for a25

select--+ ordered no_merge(s)
        lpad(s.sid,6,' ')||','||serial#  as ssid
       ,s.username                       as username
       --,s.osuser || ' @ '|| s.machine    as osuser
       ,s.osuser                         as osuser
--       ,s.WAIT_CLASS                     as WCLASS
       ,rpad(s.status||': ',10)||s.EVENT as status_event
       ,s.SECONDS_IN_WAIT                as w_secs
       ,nvl2(s.taddr,'Y','N')            as tr
     --,s.schemaname
     --,s.terminal
       ,s.program,s.sql_id
       ,nvl2( pe.owner
             ,pe.owner||'.'||pe.OBJECT_NAME
                 ||nvl2( pe.PROCEDURE_NAME
                        ,'.'||pe.PROCEDURE_NAME
                        ,null)
             ,null)              as plsql_entry_obj
       ,nvl2( po.owner
             ,po.owner||'.'||po.OBJECT_NAME
                 ||nvl2( po.PROCEDURE_NAME
                        ,'.'||po.PROCEDURE_NAME
                        ,null)
             ,null)              as plsql_obj
      --,s.BLOCKING_SESSION_STATUS is_block
      ,s.BLOCKING_SESSION        as b_sid
--      ,decode(s.TYPE,'USER','U','BACKGROUND','B','Other') type
from 
     v$session      s
    ,dba_procedures pe
    ,dba_procedures po
where 
      pe.OBJECT_ID(+) = s.PLSQL_ENTRY_OBJECT_ID
  and pe.SUBPROGRAM_ID(+) = s.PLSQL_ENTRY_SUBPROGRAM_ID
  and po.OBJECT_ID(+) = s.PLSQL_OBJECT_ID
  and po.SUBPROGRAM_ID(+) = s.PLSQL_SUBPROGRAM_ID
  and s.type='USER' /* 'BACKGROUND' */
  and sid=&1
/
col ssid             clear
col username         clear
col osuser           clear
col wclass           clear
col status_event     clear
col program          clear
col plsql_entry_obj  clear
col plsql_obj        clear
