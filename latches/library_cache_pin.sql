col KGLNAOBJ format a30
col KGLFNOBJ format a30
col KGLNADLK format a30
col KGLOBCCE format a30
col KGLOBPROP format a30
col KGLNAOWN format a30
col KGLOBTS0 format a30
col KGLOBTS1 format a30
col KGLOBTS2 format a30
col KGLOBTS3 format a30
col KGLOBTS4 format a30
col KGLOBTS5 format a30
col KGLOBTS6 format a30
col KGLOBTS7 format a30
col KGLOBTYD format a30
col KGLOBCBCA format a30
col KGLHDNSD format a30
col KGLNAHSV format a30
col KGLHDNSD format a30
col kglhdadr new_val P1RAW

select  --* 
 KGLOBTYD
,KGLNAOWN                       
,KGLNAOBJ                       
,KGLFNOBJ
,KGLNAHSV
,KGLHDADR
,ADDR
,KGLNATIM
,KGLHDNSD
from x$kglob 
where kglhdadr in( select p1raw from v$session_wait where event like 'library cache pin');

SELECT s.sid, kglpnmod "Mode", kglpnreq "Req"
    FROM x$kglpn p, v$session s
   WHERE p.kglpnuse=s.saddr
     AND kglpnhdl='&P1RAW'
  ;