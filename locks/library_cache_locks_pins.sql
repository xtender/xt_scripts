@inc/input_vars_init.sql;
REM --------------------------------------------------------------------------------------------------
REM Author: Riyaj Shamsudeen @OraInternals, LLC
REM         www.orainternals.com
REM  
REM Functionality: This script is to print identify libray cache locks and hang issues.
REM **************
REM 
REM
REM Note : 1. This SQL does not use GV$ views. So, this will not work in RAC.
REM        2. Keep window 160 columns for better visibility.
REM
REM Exectution type: Execute from sqlplus or any other tool. 
REM
REM 
REM No implied or explicit warranty
REM
REM Please send me an email to rshamsud@orainternals.com, if you enhance this script :-)
REM --------------------------------------------------------------------------------------------------
prompt 
set timing off lines 160 pages 100 

col sid             format 9999
col serial#         format 99999999
col username        format A12
col machine         format A20
col module          format A10      word_wrap
col obj_owner       format A10
col obj_name        format A20
col lock_cnt        format A5       heading 'lock|cnt'
col lock_mode       format 99       heading 'lock|mode'
col lock_req        format 99       heading 'lock|req'
col pin_cnt         format 999999   heading 'pin|cnt'
col pin_mode        format 999      heading 'pin|mode'
col pin_req         format 999999   heading 'pin|req'
col event           format A30
col wait_time       format 9999     heading 'wait|time' 
col seconds_in_Wait format 99999    heading 'seconds|in_wait' 
col state           format A10      word_wrap

set heading off
select 'Library cache pin holders/waiters' from dual
union all
select '---------------------------------' from dual;
set heading on

select
 distinct
   ses.ksusenum sid, ses.ksuseser serial#, ses.ksuudlna username,ses.ksuseunm machine,
   ob.kglnaown obj_owner, ob.kglnaobj obj_name
   ,pn.kglpncnt pin_cnt, pn.kglpnmod pin_mode, pn.kglpnreq pin_req
   , w.state, w.event, w.wait_Time, w.seconds_in_Wait
   -- lk.kglnaobj, lk.user_name, lk.kgllksnm,
   --,lk.kgllkhdl,lk.kglhdpar
   --,trim(lk.kgllkcnt) lock_cnt, lk.kgllkmod lock_mode, lk.kgllkreq lock_req,
   --,lk.kgllkpns, lk.kgllkpnc,pn.kglpnhdl
 from
    &1.x$kglpn pn
  , &1.x$kglob ob
  , &1.x$ksuse ses 
  --, &1.x$kgllk lk
  , v$session_wait w
where 
      pn.kglpnhdl in (select kglpnhdl from &1.x$kglpn where kglpnreq >0 )
  and ob.kglhdadr = pn.kglpnhdl
  and pn.kglpnuse = ses.addr
  and w.sid = ses.indx
order by seconds_in_wait desc
/

set heading off
select 'Library cache lock holders/waiters' from dual
union all
select '---------------------------------' from dual;
set heading on
select
 distinct
   ses.ksusenum sid, ses.ksuseser serial#, ses.ksuudlna username,KSUSEMNM module,
   ob.kglnaown obj_owner, ob.kglnaobj obj_name
   -- lk.kglnaobj, lk.user_name, lk.kgllksnm,
   --,lk.kgllkhdl,lk.kglhdpar
   --,trim(lk.kgllkcnt) lock_cnt, lk.kgllkmod lock_mode, lk.kgllkreq lock_req,
   ,lk.kgllkcnt lck_cnt, lk.kgllkmod lock_mode, lk.kgllkreq lock_req
   --,lk.kgllkpns, lk.kgllkpnc,pn.kglpnhdl
--  , (select x$kgllk lk
 , w.state, w.event, w.wait_Time, w.seconds_in_Wait
 from
    &1.x$kgllk lk
  , &1.x$kglob ob
  , &1.x$ksuse ses
  --, &1.x$kgllk lk
  , v$session_wait w
where 
      lk.kgllkhdl in (select kgllkhdl from &1.x$kgllk where kgllkreq >0 )
  and ob.kglhdadr = lk.kgllkhdl
  and lk.kgllkuse = ses.addr
  and w.sid = ses.indx
order by seconds_in_wait desc
/
@inc/input_vars_undef.sql;
