prompt Enter filters(empty for any)...
accept _sid         prompt "Sid           : ";
accept _globalid    prompt "Globalid mask : ";
accept _remote_db   prompt "Remote_db mask: ";


col remote_db               for a20;
--col remote_dbid_reversed    for a10;
col trans_id                for a16;
col direction               for a11;
col globalid                for a80;
col globalid_ora            for a40 noprint;
col branchid                for a80 noprint;
col branches                noprint;
col refcount                noprint;
col preparecount            noprint;
col flags                   noprint;
col formatid                noprint;
col state                   for a40;
col coupling                for a15;
col username                for a30;
col osuser                  for a30;
col event                   for a35;
col wait_class              for a10;
col status                  for a10;
col trx_start_time          for a18;
col db_trx                  for a80;
with
 v_global as (
    select 
      v2.*
     ,to_number(regexp_replace(trans_id,'^(\d+)\.(\d+)\.(\d+)$','\1')) as xidusn
     ,to_number(regexp_replace(trans_id,'^(\d+)\.(\d+)\.(\d+)$','\2')) as xidslot
     ,to_number(regexp_replace(trans_id,'^(\d+)\.(\d+)\.(\d+)$','\3')) as xidsqn
    from (
      select 
         v1.globalid 
        ,v1.branchid 
        ,v1.state
        ,v1.coupling
        ,v1.branches
        ,v1.refcount
        ,v1.preparecount
        ,v1.db_trx
        ,                           regexp_replace(v1.db_trx,'^(.*)\.(\w+)\.(\d+\.\d+\.\d+)$','\1') as remote_db
        ,                           regexp_replace(v1.db_trx,'^(.*)\.(\w+)\.(\d+\.\d+\.\d+)$','\3') as trans_id
        ,to_number(hextoraw(reverse(regexp_replace(v1.db_trx,'^(.*)\.(\w+)\.(\d+\.\d+\.\d+)$','\2'))),'XXXXXXXXXXXXXXXXXX') as remote_dbid
      from 
         (
            select t.* 
                   ,regexp_substr(utl_raw.cast_to_varchar2(globalid),'^(\w|\.)+$') db_trx
            from v$global_transaction t
         ) v1
      ) v2
)
select 
    g.remote_db
   ,nvl2(replace(g.branchid,'0'),'FROM REMOTE','TO REMOTE') as direction
   ,g.trans_id
   ,t.start_time as trx_start_time
   ,s.sid,s.serial#
   ,s.username
   ,s.osuser
--   ,s.sql_id
   ,s.wait_class
   ,s.status
   ,s.event
   ,g.remote_dbid
   ,g.globalid 
   ,g.branchid 
   ,g.state
   ,g.coupling
--   ,g.xidusn 
--   ,g.xidslot
--   ,g.xidsqn 
--   ,g.branches
--   ,g.refcount
--   ,g.preparecount
   ,g.db_trx
from v_global  g
    ,v$transaction t
    ,v$session s
where 
      g.xidusn  = t.xidusn(+)
  and g.xidslot = t.xidslot(+)
  and g.xidsqn  = t.xidsqn(+)
  and t.SES_ADDR = s.saddr(+)
  and ('&_sid'       is null or s.sid       ='&_sid')
  and ('&_globalid'  is null or g.globalid  like '&_globalid')
  and ('&_remote_db' is null or g.remote_db like '&_remote_db')
/
col remote_db               clear;
--col remote_dbid_reversed    clear;
col trans_id                clear;
col direction               clear;
col globalid                clear;
col globalid_ora            clear;
col branchid                clear;
col state                   clear;
col coupling                clear;
col username                clear;
col osuser                  clear;
col event                   clear;
col wait_class              clear;
col status                  clear;
col trx_start_time          clear;
col db_trx                  clear;
undef  _sid      ;
undef  _globalid ;
undef _remote_db ;

prompt;
prompt;