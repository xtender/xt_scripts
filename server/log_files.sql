col MEMBER for a75;
select * from v$logfile order by type,group#,member;
col MEMBER clear;