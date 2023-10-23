@inc/input_vars_init

prompt ************************************************************************************
prompt * RTSM reports saved to AWR history
prompt * params:
prompt * 1. sql_id
prompt * 2. count of the most recent executions to display [optional, default = 20]
prompt * 3. number of days back the script evaluates       [optional, default = no limit]
prompt ************************************************************************************

col lst new_val last_executions_to_show  noprint;
col dd  new_val last_days_filter         noprint;
select
  case when '&2' is null then '20' else '&2' end lst,
  case when '&3' is null then '--' else '  ' end dd
from dual;
pro * Searching last &last_executions_to_show executions of &1 :

col sql_id         format a13;
col exec_start     format a20;
col DOP            format 999;
with
function get_key(key in varchar2, num int) return number is 
  str  varchar2(100):= regexp_substr(key,'[^#]+',1,num);
  fstr varchar2(100):= '0'||str;
  frmt varchar2(100):= translate(fstr,'.0123456789','d9999999999');
  fnls varchar2(100):=q'{NLS_NUMERIC_CHARACTERS = '.,'}';
begin
  return to_number(fstr DEFAULT null ON CONVERSION ERROR,frmt,fnls);
end;
reps as (
  select 
     report_id
    ,period_start_time
    ,key1                      as sql_id
    ,to_number(key2)           as sql_exec_id
    ,key3                      as sql_exec_start
    ,get_key(key4,1)           as duration
    ,get_key(key4,2)/1e6       as ela_sec
    ,get_key(key4,3)/1e6       as cpu_sec
    ,get_key(key4,4)           as read_reqs
    ,get_key(key4,5)/1024/1024 as read_mb
    ,report_summary
    ,key4
    ,r.dbid, r.instance_number as inst, r.snap_id
  --  ,sn.begin_interval_time    as snap_beg
  &&last_days_filter  ,sn.end_interval_time      as snap_end
  from dba_hist_reports r
    &&last_days_filter     ,dba_hist_snapshot sn
  where 1=1
    and r.component_name = 'sqlmonitor'
    and r.key1        like '&1'
    &&last_days_filter   and r.dbid            = sn.dbid(+)
    &&last_days_filter   and r.instance_number = sn.instance_number(+) 
    &&last_days_filter   and r.snap_id         = sn.snap_id(+)
    &&last_days_filter   and sn.end_interval_time > sysdate - &&3
  order by r.snap_id desc, r.period_start_time desc
  fetch first &last_executions_to_show rows only
)
SELECT-- NO_XML_QUERY_REWRITE
      t.report_id
    &&last_days_filter ,snap_id
    , t.period_start_time
    , t.sql_id
    --, t.sql_exec_id    as exec_id
    --, t.sql_exec_start as exec_start
    , t.duration
    , t.ela_sec
    , t.cpu_sec
    , t.read_reqs
    , round(t.read_mb,1) read_mb
    
    ,x.sql_id        
    ,x.sql_exec_start
    ,x.sql_exec_id   
    ,x.status        
    --,x.sql_text      
    --,x.sid           
    --,x.serial        
    --,x.username         
    --,x.module        
    --,x.program       
    ,x.plan_hash     
    ,x.dop           
    ,x.px_requested  
    ,x.px_allocated  
    --,x.duration      
    ,round(x.elapsed_time /1e6,4) x_ela_sec
    ,round(x.cpu_time     /1e6,4) x_cpu_sec
    ,round(x.io_time      /1e6,4) x_io_sec
    ,round(x.other_time   /1e6,4) x_oth_sec
    ,x.buffer_gets   
    --,x.read_reqs     
    --,x.read_bytes    
FROM 
    reps t
    outer apply(
     xmltable('/report_repository_summary/sql'    
       PASSING xmlparse(document t.report_summary)    
       COLUMNS    
        sql_id         varchar2(13) path '@sql_id'     
       ,sql_exec_start varchar2(20) path '@sql_exec_start'    
       ,sql_exec_id    number       path '@sql_exec_id'      
       ,status         varchar2(20) path 'status'    
       ,sql_text       varchar2(80) path 'sql_text'
       ,sid            number       path 'session_id'
       ,serial         number       path 'session_serial'
       ,username       varchar2(30) path 'user'
       ,module         varchar2(64) path 'module'
       ,program        varchar2(64) path 'program'
       ,plan_hash      number       path 'plan_hash'
       ,dop            number       path 'dop'
       ,px_requested   number       path 'px_servers_requested'
       ,px_allocated   number       path 'px_servers_allocated'
       ,duration       number       path 'stats/stat[@name="duration"]'  
       ,elapsed_time   number       path 'stats/stat[@name="elapsed_time"]'  
       ,cpu_time       number       path 'stats/stat[@name="cpu_time"]'  
       ,io_time        number       path 'stats/stat[@name="user_io_wait_time"]'
       ,other_time     number       path 'stats/stat[@name="other_wait_time"]'
       ,buffer_gets    number       path 'stats/stat[@name="buffer_gets"]'
       ,read_reqs      number       path 'stats/stat[@name="read_reqs"]'
       ,read_bytes     number       path 'stats/stat[@name="read_bytes"]'
     )) x 
;
/
col sql_id     clear;
col exec_start clear;
@inc/input_vars_undef;