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

prompt Enabling PLSQL_TRACE(event 10928, level 1) for session (&_predicate):
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

prompt Spooling into &_SPOOLS./to_exec.sql
prompt Will be executed:
prompt 
spool &_SPOOLS./to_exec.sql
prompt &_IF_MORE prompt Too many rows. Please set params right. Exiting...
prompt &_IF_ONE oradebug setospid &_trace_os_pid
prompt &_IF_ONE oradebug EVENT 10928 trace name context forever, level 1
spool off
prompt /*############################*/
prompt
Pause If anything wrong press Ctrl+C. Otherwise press enter to enable plsql trace on session...
@&_SPOOLS./to_exec.sql