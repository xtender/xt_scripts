@inc/input_vars_init
set serverout on
prompt
prompt &_C_REVERSE.***       Runstats by sid        *** &_C_RESET
prompt Syntax @runstats/sid [interval [latches [stats]]]
prompt * interval(integer) - interval between snaps, default=5 seconds
prompt * latches (boolean) - enable/disable latches snapping for all system [false]
prompt * stats   (booleab) - enable/disable stats snapping for specified SID[true]
prompt =========================================================
column r_sid      new_value r_sid     ;
column r_interval new_value r_interval;
column r_latches  new_value r_latches ;
column r_stats    new_value r_stats   ;
select
   nvl(to_number('&1'),sys_context('userenv','sid')) r_sid
  ,nvl('&2'+0,5)                               r_interval
  ,decode(upper('&3'),'TRUE' ,'true' ,'false') r_latches
  ,decode(upper('&4'),'FALSE','false','true' ) r_stats
from dual;

begin
   xt_runstats.init(p_sid => &r_sid,p_latches => &r_latches,p_stats => &r_stats);
   xt_runstats.snap('Start');
   dbms_lock.sleep(&r_interval);
   xt_runstats.snap('End');
   xt_runstats.print();
end;
/
set serverout off
column r_sid      clear
column r_interval clear
column r_latches  clear
column r_stats    clear
undef r_sid r_interval r_latches r_stats
@inc/input_vars_undef
