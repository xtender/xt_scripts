set termout off
col "_by_sid"  new_val _by_sid
col "_by_mask" new_val _by_mask
select 
   case 
      when translate('&1','x0123456789','x') is null and '&1' is not null 
       then ''
       else '--'
   end "_by_sid"
  ,case 
      when translate('&1','x0123456789','x') is null and '&1' is not null 
       then '--'
       else ''
   end "_by_mask"
from dual;
col by_sid  clear;
col by_mask clear;
set termout on

col username    format  a20
col inst        format  999
col serial      format  a7
col event       format  a30
col wait_class  format  a15
col osuser      format  a12
col machine     format  a15
col action      format  a15
col client_info format  a15
col client_ident format a15
col program     format  a15
col terminal    format  a20
col module      format  a20
col os_pid      format  a7
col ora_pid     format  a10
col pe_object   format  a35
col po_object   format  a35
col sql_exec_start  format a14 heading sql_started
col p1          format  a16;
col p2          format  a16;
col p3          format  a16;
col p1text      format  a16;
col p2text      format  a16;
col p3text      format  a16;

with u_info as (
   select--+ leading(s p pe po) no_merge(s)
      s.USERNAME                                   as username
     ,s.inst_id                                    as inst
     ,s.sid                                        as sid
     ,trim(s.serial#                             ) as serial
     ,s.serial#                                    as serial#
     ,s.osuser                                     as osuser
     ,s.machine                                    as machine
     ,s.action
     ,s.client_info
     ,s.client_identifier
     ,s.event                                      as event
     ,s.wait_class                                 as wait_class
     ,s.TERMINAL                                   as terminal
     ,s.program                                    as program
     ,s.module                                     as module
     ,p.spid                                       as spid
     ,p.spid                                       as os_pid
     ,p.pid                                        as pid
     ,p.pid                                        as ora_pid
     ,s.sql_id                                     as sql_id
&_IF_ORA11_OR_HIGHER     ,to_char(s.sql_exec_start,'dd/mm hh24:mi:ss')   as sql_exec_start
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
     ,s.p1text
     ,s.p1
     ,s.p2text
     ,s.p2
     ,s.p3text
     ,s.p3
   from 
        gv$session s
       ,gv$process  p
       ,dba_procedures pe
       ,dba_procedures po
   where 
        s.paddr = p.addr
    and s.inst_id = p.inst_id
    and pe.OBJECT_ID    (+)    = s.PLSQL_ENTRY_OBJECT_ID
    and pe.SUBPROGRAM_ID(+)    = s.PLSQL_ENTRY_SUBPROGRAM_ID
    and po.OBJECT_ID    (+)    = s.PLSQL_OBJECT_ID
    and po.SUBPROGRAM_ID(+)    = s.PLSQL_SUBPROGRAM_ID
    &_by_sid.  and sid=&1
    &_by_mask. and (upper(osuser) like upper('%&1%') or s.username like upper('%&1%'))
)
select--+ gather_plan_statistics
    username
    ,inst
    ,sid
    ,serial
    ,osuser
    ,machine
    ,action
    ,client_info
    ,client_identifier as client_ident
    ,event
    ,wait_class
--    ,terminal
    ,program
    ,module
    ,os_pid
    ,ora_pid||'' as ora_pid
    ,sql_id
    ,p1text
    ,to_char(p1,'tm9')  as p1
    ,p2text             as p2text
    ,to_char(p2,'tm9') as p2
    ,p3text             as p3text
    ,to_char(p3,'tm9') as p3
&_IF_ORA11_OR_HIGHER    ,sql_exec_start
    ,pe_object
    ,po_object
from u_info
/
col username    clear;
col inst        clear;
col serial      clear;
col event       clear;
col wait_class  clear;
col osuser      clear;
col machine     clear;
col action      clear;
col client_info clear
col client_ident clear
col program     clear;
col terminal    clear;
col module      clear;
col os_pid      clear;
col ora_pid     clear;
col pe_object   clear;
col po_object   clear;
col sql_exec_start  clear;
col p1          clear;
col p2          clear;
col p3          clear;
col p1text      clear;
col p2text      clear;
col p3text      clear;
