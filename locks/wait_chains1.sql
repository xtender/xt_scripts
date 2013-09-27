rem -----------------------------------------------------------------------------------------
rem From http://alexzeng.wordpress.com/2012/06/01/get-the-final-blocker-sessions-in-oracle/
rem -----------------------------------------------------------------------------------------
set head off;
column w_proc           format a50 tru
column instance         format a20 tru
column inst             format a28 tru
column wait_event       format a50 tru
column p1               format a16 tru
column p2               format a16 tru
column p3               format a15 tru
column Seconds          format a50 tru
column sincelw          format a50 tru
column blocker_proc     format a50 tru
column fblocker_proc    format a50 tru
column waiters          format a50 tru
column chain_signature  format a100 wra
column blocker_chain    format a100 wra
 
select *
from (
        select 
         'Current Process: '||osid W_PROC, 'SID '||i.instance_name AS INSTANCE
        ,'INST #: '||instance INST,'Blocking Process: '||decode(blocker_osid,null,'<none>',blocker_osid)||
         ' from Instance '||blocker_instance AS BLOCKER_PROC
        ,'Number of waiters: '||num_waiters AS waiters
        ,'Final Blocking Process: '||decode(p.spid,null,'<none>',p.spid)||' from Instance '||s.final_blocking_instance AS FBLOCKER_PROC
        ,'Program: '||p.program AS image
        ,'Wait Event: ' ||wait_event_text wait_event, 'P1: '||wc.p1 p1, 'P2: '||wc.p2 p2, 'P3: '||wc.p3 AS p3
        ,'Seconds in Wait: '||in_wait_secs Seconds, 'Seconds Since Last Wait: '||time_since_last_wait_secs AS sincelw
        ,'Wait Chain: '||chain_id ||': '||chain_signature chain_signature,'Blocking Wait Chain: '||decode(blocker_chain_id,null,'<none>',blocker_chain_id) AS blocker_chain
        from v$wait_chains wc,
             gv$session s,
             gv$session bs,
             gv$instance i,
             gv$process p
        where 
             wc.instance        = i.instance_number (+)
         and wc.instance        = s.inst_id (+) 
         and wc.sid             = s.sid (+)
         and wc.sess_serial#    = s.serial# (+)
         and s.inst_id          = bs.inst_id (+) 
         and s.final_blocking_session = bs.sid (+)
         and bs.inst_id         = p.inst_id (+) 
         and bs.paddr           = p.addr (+)
         and ( 
                num_waiters > 0
              or ( blocker_osid is not null and in_wait_secs > 10 ) 
            )
        order by chain_id, num_waiters desc
)
where rownum < 101;

set head on;
column w_proc           clear;
column instance         clear;
column inst             clear;
column wait_event       clear;
column p1               clear;
column p2               clear;
column p3               clear;
column Seconds          clear;
column sincelw          clear;
column blocker_proc     clear;
column fblocker_proc    clear;
column waiters          clear;
column chain_signature  clear;
column blocker_chain    clear;
