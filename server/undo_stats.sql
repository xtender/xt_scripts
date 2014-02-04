select
  begin_time, end_time, undoblks,
  unexpiredblks, expiredblks,
  activeblks,txncount,maxqueryid, maxquerylen, tuned_undoretention
from
  v$undostat
where
  end_time > trunc(sysdate)
  and rownum<10
/