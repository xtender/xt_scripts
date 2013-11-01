@inc/input_vars_init
set termout off timing off ver off feed off head off lines 10000000 pagesize 0

define _sqlid=&1

col exec new_val exec noprint;
col html new_val html noprint;

with plans as (
               select s.sql_id   
                     ,s.plan_hash_value                                               as plan_hv
                     ,listagg(s.CHILD_NUMBER,',')
                        within group(order by s.child_number)                         as child_list
                     ,min(s.child_number)                                             as child
                     ,min(p.timestamp            )                                    as min_timestamp
                     ,max(p.timestamp            )                                    as max_timestamp
                     ,sum(p.EXECUTIONS           )                                    as executions
                     ,sum(s.ELAPSED_TIME         )  / nullif(sum(s.executions),0)/1e6 as ela_time
                     ,sum(s.USER_IO_WAIT_TIME    )  / nullif(sum(s.executions),0)/1e6 as io_time
                     ,sum(s.CPU_TIME             )  / nullif(sum(s.executions),0)/1e6 as cpu_time
                     ,sum(s.IO_INTERCONNECT_BYTES)  / nullif(sum(s.executions),0)     as io_bytes
                     ,sum(s.BUFFER_GETS          )  / nullif(sum(s.executions),0)     as buff_gets
                     ,sum(s.DISK_READS           )  / nullif(sum(s.executions),0)     as disk_reads
               from 
                  v$sql s
                 ,v$sql_plan_statistics_all p
               where 
                      s.sql_id       = '&_sqlid'
                  and p.sql_id       = s.sql_id
                  and p.CHILD_NUMBER = s.CHILD_NUMBER
                  and p.id           = 0
               group by s.sql_id,s.plan_hash_value 
),plans2 as (
            select 
                 sql_id
               , plan_hv
               , child
               , child_list
               , to_char(min_timestamp,'yyyy-mm-dd hh24:mi:ss') as min_timestamp
               , to_char(max_timestamp,'yyyy-mm-dd hh24:mi:ss') as max_timestamp
               , to_char(executions,  '9999999999999990')       as executions
               , to_char(ela_time  ,  '999999990.999990')       as ela_time
               , to_char(io_time   ,  '999999990.999990')       as io_time
               , to_char(cpu_time  ,  '999999990.999990')       as cpu_time
               , to_char(io_bytes  ,  '999G9999G999G990')       as io_bytes
               , to_char(buff_gets ,  '9999999999990.90')       as buff_gets
               , to_char(disk_reads,  '9999999999990.90')       as disk_reads
               , row_number()over(order by max_timestamp)       as rn
            from plans
)
--order by max_timestamp
select 
   listagg('@inc/active "'||p.sql_id||'" "'||p.child||'" "'||p.plan_hv||'"'
           ,chr(10)
          ) within group(order by p.max_timestamp)
    as exec
  ,listagg('<td><pre>'
           ||'plan_hv       ='||p.plan_hv||'<br/>'
           ||'child_list    ='||p.child_list||'<br/>'
           ||'min_timestamp ='||p.min_timestamp||'<br/>'
           ||'max_timestamp ='||p.max_timestamp||'<br/>'
           ||'executions    ='||p.executions||'<br/>'
           ||'ela_time      ='||p.ela_time||'<br/>'
           ||'io_time       ='||p.io_time||'<br/>'
           ||'cpu_time      ='||p.cpu_time||'<br/>'
           ||'io_bytes      ='||p.io_bytes||'<br/>'
           ||'buff_gets     ='||p.buff_gets||'<br/>'
           ||'disk_reads    ='||p.disk_reads||'<br/></pre>'
           ||'<iframe '
                    ||' width="700" height="2000" '
                    ||' src="./plan_lc_'||p.sql_id||'_'||p.plan_hv||'_'||p.child||'.html" '
           ||'></iframe></td>'
          ,chr(10)
          ) within group(order by p.rn)
    as infos
  ,listagg('<td>'
           ||'<iframe '
                    ||' width="700" height="2000" '
                    ||' src="./plan_lc_'||p.sql_id||'_'||p.plan_hv||'_'||p.child||'.html" '
           ||'></iframe></td>'
          ,chr(10)
          ) within group(order by p.rn)
    as iframes
from plans2 p;

define _efile='&_TEMPDIR\plan_lc_&_sqlid..sql'
spool &_efile
prompt &exec
spool off
@&_efile

define _hfile="&_TEMPDIR\plan_lc_&_sqlid..html"
spool &_hfile
prompt <html><body><table border=1><tr>
prompt &html
prompt </tr></table></body></html>
spool off
host &_START &_hfile

undef _sqlid _hfile _efile exec
@inc/input_vars_undef
