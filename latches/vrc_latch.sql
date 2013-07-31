col name format a30
col addr new_val _addr
col fname new_val fname noprint
select '&_TEMPDIR/latches/rc_latch_'||to_char(sysdate,'yyyy-mm-dd hh24.mi.ss."spool.sql"') fname from dual;
spool "&fname"

select * from v$latch_parent where name like 'Result Cache: RC Latch';

@@vlatch_stats_11g.sql "&_addr"
spool off
prompt Spooled to "&fname"