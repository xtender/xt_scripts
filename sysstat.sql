col STATISTIC#  format 999999
col NAME        format a64
col CLASS       format 999999
col VALUE       format clear
col STAT_ID     format clear
select * from v$sysstat ss where lower(ss.name) like lower('%&1%');
col STATISTIC#  clear
col NAME        clear
col CLASS       clear