--col target for a40;
col status              for a10;
col opname              for a35;
col target_desc         for a45 heading "Target/Target Desc";
col progress            for a20;
col units               for a10;
col message             for a50;
col username            for a20;
col sql_plan_operation  for a20;
col sql_plan_options    for a25;

select 
  l.sid
 ,l.serial#
 ,l.qcsid
 ,case when sofar=totalwork then 'Finished'
       when sofar>totalwork then 'More than estimated'
       when sofar<totalwork then to_char(sofar*100/totalwork,'999.0')||'%'
  end status
 ,l.start_time
 ,l.last_update_time
 ,l.opname
 ,l.target ||'/'|| l.target_desc as target_desc
 ,l.sofar||'/'||l.totalwork as progress
 ,l.units
 ,l.elapsed_seconds
 ,l.time_remaining
 ,l.message
 ,l.username
 ,l.sql_id
 ,l.sql_plan_line_id
 ,l.sql_plan_operation
 ,l.sql_plan_options
from v$session_longops l 
where l.sid = &1
order by l.start_time,l.last_update_time
/
col status              clear;
col opname              clear;
col target_desc         clear;
col progress            clear;
col units               clear;
col message             clear;
col username            clear;
col sql_plan_operation  clear;
col sql_plan_options    clear;