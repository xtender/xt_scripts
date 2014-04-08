@inc/input_vars_init
prompt 
prompt &_C_RED *** Temp usage by sid or top session by tempseg_usage.&_C_RESET;
prompt &_C_REVERSE * Usage: @temp_usage [sid]&_C_RESET;

col username format a25;
col program  format a30;
col terminal format a30;

col TABLESPACE format a20;
col CONTENTS   format a15;
col SQL_ID     format a13;
col U_SQLID    format a13;
col SQLADDR    format a16;
col SEGTYPE    format a12;
col mbytes     format a12 heading "mem(Mbytes)";

  select 
    s.sid
   ,s.serial#
   ,s.username
   ,s.SQL_ID
   ,u.SQL_ID      u_sqlid
   ,u.SQLADDR
   ,u.TABLESPACE
   ,u.CONTENTS
   ,u.SEGTYPE
   ,u.BLOCKS
   ,to_char(u.BLOCKS*8192/1e6,'tm9') mbytes 
   ,s.program
   ,s.terminal
  from v$tempseg_usage u
      ,v$session s 
  where u.SESSION_ADDR=s.SADDR 
    and s.sid='&1' and '&1' is not null and translate('&1','z0123456789','z') is null
union all
select * 
from (
  select--+ leading(u s)
    s.sid
   ,s.serial#
   ,s.username
   ,s.SQL_ID
   ,u.SQL_ID    u_sqlid
   ,u.SQLADDR
   ,u.TABLESPACE
   ,u.CONTENTS
   ,u.SEGTYPE
   ,u.BLOCKS
   ,to_char(u.BLOCKS*8192/1e6,'tm9') mbytes
   ,s.program
   ,s.terminal
  from v$tempseg_usage u
      ,v$session s 
  where u.SESSION_ADDR=s.SADDR 
    and ('&1' is null or s.username like upper('&1'))
  order by u.blocks desc
)
where rownum<=10
/
col username clear;
col program  clear;
col terminal format a30;

col TABLESPACE clear;
col CONTENTS   clear;
col SQL_ID     clear;
col SQLADDR    clear;
col SEGTYPE    clear;

@inc/input_vars_undef
