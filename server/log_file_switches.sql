col member format a50
col bytes format 999g999g999g999g999

select a.group#, b.member, a.bytes, a.first_time, a.status
  from v$log a, v$logfile b
 where a.group# = b.group#
order by first_time,status,member
/