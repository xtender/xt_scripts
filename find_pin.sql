col username for a18
col machine     for a18
col obj_owner   for a20
col obj_name    for a30
col state       for a15
col event       for a40
prompt
prompt Finding library cache pin objects:

set termout off
col _pred   new_val _pred noprint

select 
  case 
    when '&1' is not null and translate('&1','x0123456789','x') is null 
      then 'and w.sid = &1 '
    else ' '
  end "_PRED"
from dual;

set termout on

/*
select
 distinct
    ses.ksusenum sid
  , ses.ksuseser serial#
  , ses.ksuudlna username
  , ses.ksuseunm machine
  , ob.kglnaown obj_owner
  , ob.kglnaobj obj_name
  , pn.kglpncnt pin_cnt
  , pn.kglpnmod pin_mode
  , pn.kglpnreq pin_req
  , w.state
  , w.event
  , w.wait_Time
  , w.seconds_in_Wait
   -- lk.kglnaobj, lk.user_name, lk.kgllksnm,
   --,lk.kgllkhdl,lk.kglhdpar
   --,trim(lk.kgllkcnt) lock_cnt, lk.kgllkmod lock_mode, lk.kgllkreq lock_req,
   --,lk.kgllkpns, lk.kgllkpnc,pn.kglpnhdl
 from
     &2.x$kglpn pn
  ,  &2.x$kglob ob
  ,  &2.x$ksuse ses 
  ,  v$session_wait w
where 
  pn.kglpnhdl in
          (select kglpnhdl from &2.x$kglpn where kglpnreq >0 )
  and ob.kglhdadr = pn.kglpnhdl
  and pn.kglpnuse = ses.addr
  and w.sid = ses.indx
  &_pred.
order by seconds_in_wait desc;
*/

select--+ use_hash(lk ob ses w)
 distinct
   ses.ksusenum sid, ses.ksuseser serial#, ses.ksuudlna username,KSUSEMNM module,
   ob.kglnaown obj_owner, ob.kglnaobj obj_name
   ,lk.kgllkcnt lck_cnt, lk.kgllkmod lock_mode, lk.kgllkreq lock_req
   , w.state, w.event, w.wait_Time, w.seconds_in_Wait
 from
    &2.x$kgllk lk
  , &2.x$kglob ob
  , &2.x$ksuse ses
  , v$session_wait w
where 
  lk.kgllkhdl in (select kgllkhdl from &2.x$kgllk where kgllkreq >0 )
  and ob.kglhdadr = lk.kgllkhdl
  and lk.kgllkuse = ses.addr
  and w.sid = ses.indx
  &_pred.
order by seconds_in_wait desc
/