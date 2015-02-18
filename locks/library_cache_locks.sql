@inc/input_vars_init.sql;

ttitle center 'Library cache lock holders/waiters' skip 2

column sid       format 999999
column serial    format 999999
column username  format a10
column module    format a15
column event     format a64
column obj_owner format a10
column obj_name  format a22
column state     format a8
column secs      format 999999

select
 distinct
    ses.ksusenum as sid, ses.ksuseser serial, ses.ksuudlna username,KSUSEMNM module
   , ob.kglnaown obj_owner, ob.kglnaobj obj_name
   , lk.kgllkcnt lck_cnt, lk.kgllkmod lock_mode, lk.kgllkreq lock_req
   , w.state, w.event, w.wait_Time wtime, w.seconds_in_Wait secs
 from
    sys.&1.x$kgllk lk
  , sys.&1.x$kglob ob,sys.&1.x$ksuse ses
  , v$session_wait w
where lk.kgllkhdl in (select kgllkhdl from sys.&1.x$kgllk where kgllkreq >0 )
and ob.kglhdadr = lk.kgllkhdl
and lk.kgllkuse = ses.addr
and w.sid = ses.indx
order by seconds_in_wait desc
/
ttitle off

column sid       clear;
column serial    clear;
column username  clear;
column module    clear;
column event     clear;
column obj_owner clear;
column obj_name  clear;
column state     clear;
column secs      clear;
