def _predicate=&1
col username                                format a20  JUSTIFY LEFT
col serial                                  format a7   JUSTIFY LEFT
col terminal                                format a25  JUSTIFY LEFT
col sid                                     format a10  JUSTIFY LEFT
col ora_pid                                 format a10  JUSTIFY LEFT
col os_pid      new_value   _trace_os_pid   format a10  JUSTIFY LEFT

col _CNT          new_value   _CNT      noprint
def _IF_MORE=""
def _IF_ONE="--"
col _IF_ONE       new_value   _IF_ONE   noprint
col _IF_MORE      new_value   _IF_MORE  noprint
col sid           new_value   _sid
col serial        new_value   _serial
prompt Enabling PLSQL_TRACE(event 10938, level 165) for session (&_predicate):
with u_info as (
   select
      s.USERNAME                                   as username
     ,s.sid                                        as sid
     ,trim(s.serial#                             ) as serial
     ,s.serial#                                    as serial#
     ,s.TERMINAL                                   as terminal

     ,p.spid                                       as spid
     ,p.spid                                       as os_pid
     ,p.pid                                        as pid
     ,p.pid                                        as ora_pid
   from v$session  s
       ,v$process  p
   where 
         s.paddr = p.addr
)
select 
    username
    ,sid||''     as sid
    ,serial
    ,terminal
    ,os_pid
    ,ora_pid||'' as ora_pid
    ,count(*) over()                   "_CNT"
    ,decode(count(*) over(),1,'','--') "_IF_ONE"
    ,decode(count(*) over(),1,'--','') "_IF_MORE"
from u_info
where &_predicate
;
set serverout on;
begin
    dbms_system.set_ev(&_sid, &_serial, 10938, 165,'');
    dbms_output.put_line('PLSQL_TRACE enabled for session: sid=&_sid serial=&_serial');
end;
/
set serverout off;
col username    clear;
col serial      clear;
col terminal    clear;
col sid         clear;
col ora_pid     clear;
col os_pid      clear;