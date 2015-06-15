@inc/input_vars_init;

prompt *** Simplified RTSM report
prompt * Usage: @rtsm/sqlid_manual SQL_ID [px]
prompt * Add "px" to show stats by slaves
prompt ;

def sql_id=&1

col if_parallel new_value _px noprint;
select decode(count(*),0,'--','  ') if_parallel
from dual 
where exists(select null from v$sql_monitor r where r.sql_id='&sql_id' and r.PX_SERVERS_REQUESTED>0)
  and lower('&2') like 'px'
/
col if_parallel clear;

col sql_id                 for a13;
col ch#                    for 999;
col "***"                  for a3;
col status                 for a13 trunc; 
col id                     for 99;
col operation              for a80;
col io                     for a12;
col read                   for a12;
col write                  for a12;

col wa_mem                  for 999g999d0;
col wa_max                  for 999g999d0;
col wa_temp                 for 999g999d0;
col wa_maxtemp              for 999g999d0;

col per_slave_rows         for a50
col per_slave_io_bytes     for a50
col per_slave_read_reqs    for a50
col per_slave_read_bytes   for a50
col per_slave_write_reqs   for a50
col per_slave_write_bytes  for a50


break on sql_id on ch# on plan_hv on exec_id on started on status skip 1

with 
sql_mon_manual
 as (
   select 
     sql_id,sql_exec_start,sql_exec_id, SQL_PLAN_HASH_VALUE, SQL_CHILD_ADDRESS
    ,status
    ,case when dense_rank()over(partition by sql_id,sql_exec_start,sql_exec_id, SQL_PLAN_HASH_VALUE, SQL_CHILD_ADDRESS order by max(LAST_CHANGE_TIME) desc nulls last) = 1
          then '-->'
          else '   '
      end "***"
    ,plan_line_id
    ,plan_operation
    ,plan_options
    ,plan_object_owner||'.'||plan_object_name   as obj_name
    ,count(sid)                                 as proc_cnt
    ,sum(starts                  )              as starts
    ,sum(output_rows             )              as output_rows
    ,sum(IO_INTERCONNECT_BYTES   )              as IO_INTERCONNECT_BYTES
    ,sum(PHYSICAL_READ_REQUESTS  )              as PHYSICAL_READ_REQUESTS 
    ,sum(PHYSICAL_READ_BYTES     )              as PHYSICAL_READ_BYTES    
    ,sum(PHYSICAL_WRITE_REQUESTS )              as PHYSICAL_WRITE_REQUESTS
    ,sum(PHYSICAL_WRITE_BYTES    )              as PHYSICAL_WRITE_BYTES   
    ,sum(WORKAREA_MEM            )              as WORKAREA_MEM           
    ,sum(WORKAREA_MAX_MEM        )              as WORKAREA_MAX_MEM       
    ,sum(WORKAREA_TEMPSEG        )              as WORKAREA_TEMPSEG       
    ,sum(WORKAREA_MAX_TEMPSEG    )              as WORKAREA_MAX_TEMPSEG   
&_px    ,listagg(output_rows              ,'/') within group(order by sid) as per_slave_rows
&_px    ,listagg(IO_INTERCONNECT_BYTES    ,'/') within group(order by sid) as per_slave_io_bytes
&_px    ,listagg(PHYSICAL_READ_REQUESTS   ,'/') within group(order by sid) as per_slave_read_reqs
&_px    ,listagg(PHYSICAL_READ_BYTES      ,'/') within group(order by sid) as per_slave_read_bytes
&_px    ,listagg(PHYSICAL_WRITE_REQUESTS  ,'/') within group(order by sid) as per_slave_write_reqs
&_px    ,listagg(PHYSICAL_WRITE_BYTES     ,'/') within group(order by sid) as per_slave_write_bytes
   from v$sql_plan_monitor r
   where r.sql_id='&sql_id'
     and r.starts>0
   group by 
     sql_id,sql_exec_start,sql_exec_id, SQL_PLAN_HASH_VALUE, SQL_CHILD_ADDRESS
    ,status
    ,plan_line_id
    ,plan_operation
    ,plan_options
    ,plan_object_owner||'.'||plan_object_name
   order by sql_id,sql_exec_start,sql_exec_id,plan_line_id
)
select 
    p.SQL_ID
   ,p.child_number      as ch#
   ,p.plan_hash_value   as plan_hv
   ,mon.sql_exec_id     as exec_id
   ,mon.sql_exec_start  as started
   ,mon.status          as status
   ,"***"
   ,p.ID
   ,LPAD(' ', depth) || p.operation ||' '|| p.options || NVL2(p.object_name, ' ['||p.object_name ||']', null) as operation
   ,mon.proc_cnt
   ,mon.starts
   ,mon.output_rows
   ,mon.PHYSICAL_READ_REQUESTS  as reqs_read
   ,mon.PHYSICAL_WRITE_REQUESTS as reqs_write
   ,case
       when mon.IO_INTERCONNECT_BYTES> (1024*1024*1024*1024) then to_char(mon.IO_INTERCONNECT_BYTES / (1024*1024*1024*1024) ,'9g999d0')||'TB'
       when mon.IO_INTERCONNECT_BYTES> (     1024*1024*1024) then to_char(mon.IO_INTERCONNECT_BYTES / (     1024*1024*1024) ,'9g999d0')||'GB'
       when mon.IO_INTERCONNECT_BYTES> (          1024*1024) then to_char(mon.IO_INTERCONNECT_BYTES / (          1024*1024) ,'9g999d0')||'MB'
       when mon.IO_INTERCONNECT_BYTES> (               1024) then to_char(mon.IO_INTERCONNECT_BYTES / (               1024) ,'9g999d0')||'KB'
                                                             else to_char(mon.IO_INTERCONNECT_BYTES                         ,'999g999')||' B'
    end io
   ,case
       when mon.PHYSICAL_READ_BYTES> (1024*1024*1024*1024) then to_char(mon.PHYSICAL_READ_BYTES / (1024*1024*1024*1024) ,'9g999d0')||'TB'
       when mon.PHYSICAL_READ_BYTES> (     1024*1024*1024) then to_char(mon.PHYSICAL_READ_BYTES / (     1024*1024*1024) ,'9g999d0')||'GB'
       when mon.PHYSICAL_READ_BYTES> (          1024*1024) then to_char(mon.PHYSICAL_READ_BYTES / (          1024*1024) ,'9g999d0')||'MB'
       when mon.PHYSICAL_READ_BYTES> (               1024) then to_char(mon.PHYSICAL_READ_BYTES / (               1024) ,'9g999d0')||'KB'
                                                           else to_char(mon.PHYSICAL_READ_BYTES                         ,'999g999')||' B'
    end as read
   ,case
       when mon.PHYSICAL_WRITE_BYTES> (1024*1024*1024*1024) then to_char(mon.PHYSICAL_WRITE_BYTES / (1024*1024*1024*1024) ,'9g999d0')||'TB'
       when mon.PHYSICAL_WRITE_BYTES> (     1024*1024*1024) then to_char(mon.PHYSICAL_WRITE_BYTES / (     1024*1024*1024) ,'9g999d0')||'GB'
       when mon.PHYSICAL_WRITE_BYTES> (          1024*1024) then to_char(mon.PHYSICAL_WRITE_BYTES / (          1024*1024) ,'9g999d0')||'MB'
       when mon.PHYSICAL_WRITE_BYTES= (               1024) then to_char(mon.PHYSICAL_WRITE_BYTES / (               1024) ,'9g999d0')||'KB'
                                                            else to_char(mon.PHYSICAL_WRITE_BYTES                         ,'999g999')||' B'
    end as write
   ,round(mon.WORKAREA_MEM        /1024/1024,1)   as wa_mem
   ,round(mon.WORKAREA_MAX_MEM    /1024/1024,1)   as wa_max
   ,round(mon.WORKAREA_TEMPSEG    /1024/1024,1)   as wa_temp
   ,round(mon.WORKAREA_MAX_TEMPSEG/1024/1024,1)   as wa_maxtemp
&_px   ,per_slave_rows
&_px   ,per_slave_io_bytes
&_px   ,per_slave_read_reqs
&_px   ,per_slave_read_bytes
&_px   ,per_slave_write_reqs
&_px   ,per_slave_write_bytes
from v$sql_plan p
     join sql_mon_manual mon
          on  mon.SQL_ID              = p.sql_id
          and mon.SQL_PLAN_HASH_VALUE = p.PLAN_HASH_VALUE
          and mon.SQL_CHILD_ADDRESS   = p.CHILD_ADDRESS
          and mon.plan_line_id        = p.id
where 
   p.sql_id = '&sql_id'
order by p.sql_id,p.CHILD_NUMBER, mon.sql_exec_id, p.id
/
col operation              clear; 
col per_slave_rows         clear; 
col per_slave_io_bytes     clear; 
col per_slave_read_reqs    clear; 
col per_slave_read_bytes   clear; 
col per_slave_write_reqs   clear; 
col per_slave_write_bytes  clear; 
clear break;
@inc/input_vars_undef;
