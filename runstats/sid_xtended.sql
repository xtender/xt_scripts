--@inc/input_vars_init
@inc/parse_params;
prompt
prompt &_C_REVERSE.***       Runstats by sid        *** &_C_RESET
prompt Syntax @runstats/sid [interval=N] [latches=true/false] [stats=true/false] [latch_mask=STRING] [stat_mask=STRING]
prompt * interval(integer) - interval between snaps, default=5 seconds
prompt * latches (boolean) - enable/disable latches snapping for all system [false]
prompt * stats   (booleab) - enable/disable stats snapping for specified SID[true]
prompt * latch_mask/stat_mask   (string) - regexp mask [.]
prompt =========================================================
---------------------------------------------------------------
def r_sid=&1
---------------------------------------------------------------
column interval     new_value interval;
column latches      new_value latches ;
column stats        new_value stats   ;
column latch_mask   new_value latch_mask;
column stat_mask    new_value stat_mask;
set termout off;
   select '' "INTERVAL",'' latches, '' stats, '' latch_mask, '' stat_mask from dual where 1=0;
set termout on;
column interval     clear;
column latches      clear;
column stats        clear;
column latch_mask   clear;
column stat_mask    clear;
---------------------------------------------------------------
column r_interval   new_value r_interval;
column r_latches    new_value r_latches ;
column r_stats      new_value r_stats   ;
column r_latch_mask new_value r_latch_mask;
column r_stat_mask  new_value r_stat_mask;
select
   nvl('&interval'+0,5)                               r_interval
  ,decode(upper('&latches'),'TRUE' ,'true' ,'false')  r_latches
  ,decode(upper('&stats'  ),'FALSE','false','true' )  r_stats
  ,nvl('&latch_mask','.')                              r_latch_mask
  ,nvl('&stat_mask' ,'.')                              r_stat_mask
from dual;
column r_interval   clear;
column r_latches    clear;
column r_stats      clear;
column r_latch_mask clear;
column r_stat_mask  clear;
---------------------------------------------------------------
set serverout on
begin
   xt_runstats.init(p_sid => &r_sid,p_latches => &r_latches,p_stats => &r_stats);
   xt_runstats.snap('Start');
   dbms_lock.sleep(&r_interval);
   xt_runstats.snap('End');
   xt_runstats.print(p_latches_mask => '&r_latch_mask',p_stats_mask => '&r_stat_mask');
end;
/
set serverout off
undef r_sid r_interval r_latches r_stats
@inc/input_vars_undef
