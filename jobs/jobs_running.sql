prompt &_C_RED  *** Show current running jobs. &_C_RESET
prompt &_C_REVERSE * Usage: @jobs/jobs_running [filter] &_C_RESET
prompt ;
@inc/input_vars_init;

col "log_user/priv_user/schema_user" format a50;
col WHAT            format a40 word;
col USERNAME        format a22;
col event           format a30 word;
col WAIT_CLASS      format a20;
col STATUS          format a8;
col SQL_ID          format a13;
col SQL_EXEC_START  format a19;
select--+ leading(r j s) use_nl(j) use_nl(s)
        row_number()over(order by what) "#"
       ,r.sid,r.job,r.this_date
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
    ,v$session s
    ,dba_jobs j
where r.job=j.JOB(+)
  and r.sid=s.sid(+)
  and ('&1' is null or s.SQL_ID like '&1' or lower(s.USERNAME) like lower('&1%') or lower(j.what) like lower('%&1%') or lower(log_user) like lower('&1%') or r.sid like '&1')
order by what;

col "log_user/priv_user/schema_user"    clear;
col WHAT            clear;
col USERNAME        clear;
col event           clear;
col WAIT_CLASS      clear;
col STATUS          clear;
col SQL_ID          clear;
col SQL_EXEC_START  clear;
@inc/input_vars_undef;