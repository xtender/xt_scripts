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
col event                   for a35;
col wait_class              for a10;

with v$xt_global_transaction as (
   select
       g.inst_id                                                                       as inst_id
      ,g.k2gtdses                                                                      as saddr
      ,regexp_replace(g.k2gtitid_ora,'^(.*)\.(\w+)\.(\d+\.\d+\.\d+)$','\1')            as remote_db
--      ,regexp_replace(g.k2gtitid_ora,'^(.*)\.(\w+)\.(\d+\.\d+\.\d+)$','\2')            as remote_dbid_reversed
      ,to_number(hextoraw(reverse(regexp_replace(g.k2gtitid_ora,'^(.*)\.(\w+)\.(\d+\.\d+\.\d+)$','\2'))),'XXXXXXXXXXXX') as remote_dbid
      ,regexp_replace(g.k2gtitid_ora,'^(.*)\.(\w+)\.(\d+\.\d+\.\d+)$','\3')            as trans_id
      ,nvl2(replace(g.k2gtibid,'0'),'FROM REMOTE','TO REMOTE')                         as direction
      ,g.k2gtitid_ext  /* utl_raw.cast_to_varchar2(k2gtitid_ext) = g.k2gtitid_ora */   as globalid    
      ,g.k2gtitid_ora  /* utl_raw.cast_to_varchar2(k2gtitid_ext) = g.k2gtitid_ora */   as globalid_ora
      ,g.k2gtibid                                                                      as branchid
      ,g.k2gtecnt                                                                      as branches
      ,g.k2gterct                                                                      as refcount
      ,g.k2gtdpct                                                                      as preparecount
      ,g.k2gtifmt                                                                      as formatid
      , decode(bitand(g.k2gtdflg, 512) , 512 ,'[ORACLE COORDINATED]')
      ||decode(bitand(g.k2gtdflg,1024) ,1024 ,'[MULTINODE]')
      ||decode(bitand(g.k2gtdflg, 511)
                                       ,0    ,'ACTIVE'
                                       ,1    ,'COLLECTING'
                                       ,2    ,'FINALIZED'
                                       ,4    ,'FAILED'
                                       ,8    ,'RECOVERING'
                                       ,16   ,'UNASSOCIATED'
                                       ,32   ,'FORGOTTEN'
                                       ,64   ,'READY FOR RECOVERY'
                                       ,128  ,'NO-READONLY FAILED'
                                       ,256  ,'SIBLING INFO WRITTEN'
             )                                                                         as  state
       ,g.k2gtdflg                                                                     as flags
       ,DECODE(g.k2gtetyp
                 ,0 ,'FREE'
                 ,1 ,'LOOSELY COUPLED'
                 ,2 ,'TIGHTLY COUPLED')                                                as coupling
   from   x$k2gte2 g
         ,x$ktcxb t
         ,x$ksuse s
   where  g.k2gtdxcb = t.ktcxbxba
   and    g.k2gtdses = t.ktcxbses
   and    s.addr     = g.k2gtdses
)
select
     tr.inst_id
    ,s.sid
    ,s.serial#
    ,s.username
--    ,tr.saddr
    ,tr.remote_db
--    ,tr.remote_dbid_reversed
    ,tr.remote_dbid
    ,tr.trans_id
    ,tr.direction
    ,tr.globalid
    ,tr.globalid_ora
    ,s.event
    ,s.wait_class
    ,tr.branchid
    ,tr.branches
    ,tr.refcount
    ,tr.preparecount
    ,tr.formatid
    ,tr.state
    ,tr.flags
    ,tr.coupling
from v$xt_global_transaction tr
    ,v$session s
where tr.saddr=s.saddr
  and ('&_sid'       is null or s.sid='&_sid')
  and ('&_globalid'  is null or tr.globalid like '&_globalid')
  and ('&_remote_db' is null or tr.remote_db like '&_remote_db')
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
col event                   clear;
col wait_class              clear;
undef  _sid      ;
undef  _globalid ;
undef _remote_db ;
