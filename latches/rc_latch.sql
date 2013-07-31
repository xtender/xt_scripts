col name format a30
col addr new_val _addr

select * from v$latch_parent where name like 'Result Cache: RC Latch';

@@latch_stats_11g.sql "&_addr"
