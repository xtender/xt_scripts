col min         format 9999;
col program     format a20;
col sid         format 999999;
col status      format a10;
col sdate       format a18;
col username    format a20;
col module      format a30;
SELECT /*+ ordered*/
  round(l.ctime / 60) min
  ,t.log_io
  ,to_char(sysdate - l.ctime / 3600 / 24,'yy.mm.dd hh24:mi:ss') sdate
  ,s.username
  ,s.MODULE
  ,s.program
  ,s.sid
  ,s.status
  ,o.object_name
--  ,'kill -9 ' || p.SPID
--  ,'alter system kill session '''||s.SID||','||s.SERIAL#||''';'
--  ,'sys.od_killsession('||s.SID||');'
   FROM V$LOCK L, DBA_OBJECTS O, v$session s, v$process p, v$transaction t
  WHERE O.OBJECT_ID = L.ID1
    AND o.owner <> 'SYS'
    AND l.sid = s.sid
    and o.object_name like upper('%&tab_mask%')
    and p.Addr(+) = s.Paddr
    and ctime > 1
    and s.STATUS='ACTIVE'
    and s.saddr = t.ses_addr
--    and (s.PROGRAM like 'loan%' or s.ACTION like 'PSB_START%')
--and s.USERNAME like 'F1%'
  ORDER BY t.log_io desc,ctime desc
  /
