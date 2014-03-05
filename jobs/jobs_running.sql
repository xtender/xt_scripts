col "log_user/priv_user/schema_user" format a50;
col WHAT        format a40 word;
col USERNAME    format a22;
col event       format a30 word;
col WAIT_CLASS  format a20;
col STATUS      format a8;
col SQL_ID      format a13;

select--+ leading(r j s) use_nl(j) use_nl(s)
        r.sid,r.job,r.this_date
       ,log_user||'/'||priv_user||'/'||schema_user "log_user/priv_user/schema_user"
       ,total_time
       --,s.USERNAME
       ,s.STATUS
       ,s.WAIT_CLASS
       ,s.event
       ,s.WAIT_TIME
       ,s.SQL_ID
       ,s.SQL_EXEC_ID
       ,s.SQL_EXEC_START
       ,what
from dba_jobs_running r
    ,dba_jobs j
    ,v$session s
where r.job=j.JOB
and r.sid=s.sid
order by what;

col "log_user/priv_user/schema_user"    clear;
col WHAT        clear;
col USERNAME    clear;
col event       clear;
col WAIT_CLASS  clear;
col STATUS      clear;
col SQL_ID      clear;