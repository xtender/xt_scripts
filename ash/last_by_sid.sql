col sql_id      for a13;
col last_time   for a23;
col text        for a80 trunc;


accept _sid    prompt "SID: ";
accept _serial prompt "Serial: ";

select sql_id
      ,sql_exec_id
      ,last_time
      ,cnt
      ,sql_exec_start
      ,(select substr(sql_text,1,80) from v$sqlarea a where a.sql_id=v.sql_id) text
from (
      select sql_id,sql_exec_id,sql_exec_start
            ,max(sample_time) as last_time
            ,count(*)         as cnt
      from v$active_session_history h 
      where h.session_id      = &_sid
        and h.session_serial# = &_serial
      group by sql_id,sql_exec_id,sql_exec_start
      order by last_time desc,sql_exec_start desc
) v
where rownum<10
/
col sql_id      clear;
col text        clear;

undef _sid   ;
undef _serial;
