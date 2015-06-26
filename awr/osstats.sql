col db_name         new_val _awr_db_name     for a20;
col beg_date        new_val _awr_db_beg_date noprint;
col version         for a12;
col instance_name   for a20;
col host_name       for a30;
col platform_name   for a30;
col last_startup    for a19;

select 
                        dbid, db_name, version, instance_name, host_name
&_IF_ORA11_OR_HIGHER   ,platform_name
                       ,to_char(startup_time,'yyyy-mm-dd hh24:mi:ss') as last_startup
                       ,to_char(sysdate-7,'yyyy-mm-dd')               as beg_date
from (
      select 
        dense_rank()over(partition by dbid,db_name order by startup_time desc) n
       ,i.*
      from dba_hist_database_instance i
)
where n=1
order by startup_time;

col db_name         clear;
col beg_date        clear;
col version         clear;
col instance_name   clear;
col host_name       clear;
col platform_name   clear;
col last_startup    clear;

accept _awr_db_name     prompt "DB NAME [&_awr_db_name]: " default "&_awr_db_name";
accept _awr_db_beg_date prompt "Begin date [&_awr_db_beg_date]: " default "&_awr_db_beg_date"

col beg_time for a16;
col end_time for a16;
col cpu_load for 999.0;

with
 dbids as (
    select distinct i.dbid
    from dba_hist_database_instance i
    where db_name = '&_awr_db_name'
 )
,snaps as (
    select sn.dbid, sn.snap_id, sn.instance_number
         , sn.begin_interval_time as beg_time
         , sn.end_interval_time   as end_time
         , extract(hour from sn.begin_interval_time) beg_hh
         , extract(hour from sn.end_interval_time)   end_hh
    from dbids, dba_hist_snapshot sn
    where dbids.dbid = sn.dbid
      --and sn.instance_number = 1
      and sn.end_interval_time>date'&_awr_db_beg_date'
)
,osstats as (
      select 
        sn.dbid                                   as dbid
       ,sn.snap_id                                as snap_id
       ,o.instance_number                         as instance
       ,to_char(sn.beg_time,'yyyy-mm-dd hh24:mi') as beg_time
       ,to_char(sn.end_time,'yyyy-mm-dd hh24:mi') as end_time
       --,o.stat_id
       ,o.stat_name                               as stat_name
       ,case when o.stat_name in ('NUM_CPUS','LOAD','NUM_CPU_CORES','NUM_CPU_SOCKETS','NUM_VCPUS','NUM_LCPUS','PHYSICAL_MEMORY_BYTES') -- non-cumulative
                then o.value
             else o.value - lag(o.value) over(partition by o.dbid,o.instance_number,o.stat_name order by sn.snap_id,sn.beg_time) -- cumulative
        end as value
      from snaps sn
          ,dba_hist_osstat o
      where sn.dbid    = o.dbid
        and sn.snap_id = o.snap_id
        and sn.instance_number = o.instance_number
        and o.stat_name in (
                            'NUM_CPUS'                -- non-cumulative
                           ,'LOAD'                    -- non-cumulative
                           ,'NUM_CPU_CORES'           -- non-cumulative
                           ,'NUM_CPU_SOCKETS'         -- non-cumulative
                           ,'NUM_VCPUS'               -- non-cumulative
                           ,'NUM_LCPUS'               -- non-cumulative
                           ,'PHYSICAL_MEMORY_BYTES'   -- non-cumulative
                           
                           ,'IDLE_TIME'               -- cumulative
                           ,'BUSY_TIME'               -- cumulative
                           ,'USER_TIME'               -- cumulative
                           ,'SYS_TIME'                -- cumulative
                           ,'IOWAIT_TIME'             -- cumulative
                           ,'OS_CPU_WAIT_TIME'        -- cumulative
                           ,'RSRC_MGR_CPU_WAIT_TIME'  -- cumulative
                          -- ,'AVG_IDLE_TIME'           
                          -- ,'AVG_BUSY_TIME'           
                          -- ,'AVG_USER_TIME'           
                          -- ,'AVG_SYS_TIME'            
                          -- ,'AVG_IOWAIT_TIME'         
                          )
)
,pivotted as (
      select 
         dbid
        ,snap_id
        ,instance
        ,beg_time
        ,end_time
        ,max(decode(stat_name,'NUM_CPUS'               ,value))  AS NUM_CPUS
        ,max(decode(stat_name,'LOAD'                   ,value))  AS LOAD
        ,max(decode(stat_name,'NUM_CPU_CORES'          ,value))  AS NUM_CPU_CORES
        ,max(decode(stat_name,'NUM_CPU_SOCKETS'        ,value))  AS NUM_CPU_SOCKETS
        ,max(decode(stat_name,'NUM_VCPUS'              ,value))  AS NUM_VCPUS
        ,max(decode(stat_name,'NUM_LCPUS'              ,value))  AS NUM_LCPUS
        ,max(decode(stat_name,'IDLE_TIME'              ,value))  AS IDLE_TIME
        ,max(decode(stat_name,'BUSY_TIME'              ,value))  AS BUSY_TIME
        ,max(decode(stat_name,'USER_TIME'              ,value))  AS USER_TIME
        ,max(decode(stat_name,'SYS_TIME'               ,value))  AS SYS_TIME
        ,max(decode(stat_name,'IOWAIT_TIME'            ,value))  AS IOWAIT_TIME
        ,max(decode(stat_name,'OS_CPU_WAIT_TIME'       ,value))  AS OS_CPU_WAIT_TIME
        ,max(decode(stat_name,'RSRC_MGR_CPU_WAIT_TIME' ,value))  AS RSRC_MGR_CPU_WAIT_TIME
      from osstats
      group by 
         dbid
        ,snap_id
        ,instance
        ,beg_time
        ,end_time
)
select
     snap_id
    ,instance
    ,beg_time
    ,end_time
    ,NUM_CPUS
    ,NUM_CPU_CORES                                        
    ,NUM_CPU_SOCKETS
    ,NUM_VCPUS
    ,NUM_LCPUS
    ,LOAD                                       as CPU_LOAD
    ,round(100*LOAD/NUM_CPUS)                   as CPU_LOAD_PCT
    ,round(100*BUSY_TIME/(IDLE_TIME+BUSY_TIME)) as BUSY_PCT
    ,IDLE_TIME              /100                as IDLE_TIME             
    ,BUSY_TIME              /100                as BUSY_TIME             
    ,USER_TIME              /100                as USER_TIME             
    ,SYS_TIME               /100                as SYS_TIME              
    ,IOWAIT_TIME            /100                as IOWAIT_TIME           
    ,OS_CPU_WAIT_TIME       /100                as OS_CPU_WAIT_TIME      
    ,RSRC_MGR_CPU_WAIT_TIME /100                as RSRC_MGR_CPU_WAIT_TIME
    ,(IDLE_TIME             
     +BUSY_TIME             
     --+USER_TIME             
     --+SYS_TIME              
     +IOWAIT_TIME           
     --+OS_CPU_WAIT_TIME      
     --+RSRC_MGR_CPU_WAIT_TIME
    )/100 as all_time_secs
from pivotted
where idle_time is not null
order by
  snap_id
 ,beg_time
 ,instance
/
