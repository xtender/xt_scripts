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
accept _hh_beg          prompt "Begin hour [10]: " default 10;
accept _hh_end          prompt "End   hour [18]: " default 18;
accept _awr_except_wday prompt "Except week days[sunday,saturday]: " default "sunday,saturday";

col cpu_load  for 999.0;
col CPU_GRAPH for a21;
col CPU_MAX_GRAPH for a21;
with
 dbids as (
    select--+ no_merge
      distinct i.dbid
    from dba_hist_database_instance i
    where db_name = '&_awr_db_name'
 )
,snaps as (
    select--+ leading(dbids sn) no_merge
           sn.dbid, sn.snap_id, sn.instance_number
         , sn.begin_interval_time as beg_time
         , sn.end_interval_time   as end_time
         , extract(hour from sn.begin_interval_time) beg_hh
         , extract(hour from sn.end_interval_time)   end_hh
    from dbids, dba_hist_snapshot sn
    where dbids.dbid = sn.dbid
      --and sn.instance_number = 1
      and sn.end_interval_time>date'&_awr_db_beg_date'
      and extract(hour from end_interval_time) between &_hh_beg and &_hh_end
      and (q'[&_awr_except_wday]' is null or q'[&_awr_except_wday]' not like to_char(end_interval_time,'"%"fmday"%"'))
)
,stat_names as (
            select--+ no_merge materialize
                osn.stat_id,osn.stat_name
            from dba_hist_osstat_name osn
            where
              stat_name in (
                            'NUM_CPUS'                -- non-cumulative
                           ,'LOAD'                    -- non-cumulative
                           ,'NUM_CPU_CORES'           -- non-cumulative
                           ,'NUM_CPU_SOCKETS'         -- non-cumulative
                           ,'NUM_VCPUS'               -- non-cumulative
                           ,'NUM_LCPUS'               -- non-cumulative
                           ,'PHYSICAL_MEMORY_BYTES'   -- non-cumulative
                          )
               and rownum>0
           )
,osstats as (
      select--+ leading(sn osn o) use_nl(o) index(o.s (dbid,snap_id,instance_number))
        sn.dbid                                   as dbid
       ,sn.snap_id                                as snap_id
       ,o.instance_number                         as instance
       ,sn.beg_time                               as beg_time
       ,sn.end_time                               as end_time
       ,extract(hour from end_time)               as hh
       --,o.stat_id
       ,osn.stat_name                             as stat_name
       ,o.value                                   as value
      from snaps sn
          ,stat_names osn
          ,dba_hist_osstat o
      where sn.dbid    = o.dbid
        and sn.snap_id = o.snap_id
        and sn.instance_number = o.instance_number
        and osn.stat_id = o.stat_id
)
,pivotted as (
      select--+ no_merge(osstats) no_merge
         dbid
        ,instance
        ,trunc(beg_time,'mm')                                    as month
        ,max(decode(stat_name,'NUM_CPUS'               ,value))  AS NUM_CPUS
        ,median(decode(stat_name,'LOAD'                ,value))  AS LOAD
        ,max(decode(stat_name,'LOAD'                   ,value))  AS LOAD_MAX
        ,max(decode(stat_name,'NUM_CPU_CORES'          ,value))  AS NUM_CPU_CORES
        ,max(decode(stat_name,'NUM_CPU_SOCKETS'        ,value))  AS NUM_CPU_SOCKETS
        ,max(decode(stat_name,'NUM_VCPUS'              ,value))  AS NUM_VCPUS
        ,max(decode(stat_name,'NUM_LCPUS'              ,value))  AS NUM_LCPUS
        ,max(decode(stat_name,'PHYSICAL_MEMORY_BYTES'  ,value))  AS PHYSICAL_MEMORY_BYTES
      from osstats
      group by 
         dbid
        ,instance
        ,trunc(beg_time,'mm')
)
select
     to_char(month,'yyyy-mm') as month
    ,instance
    ,NUM_CPUS
    ,NUM_CPU_CORES                                        
    ,NUM_CPU_SOCKETS
    ,NUM_VCPUS
    ,NUM_LCPUS
    ,(PHYSICAL_MEMORY_BYTES/1024/1024)                    as "PHYSICAL_MEMORY(MB)"
    ,round(100*LOAD/NUM_CPUS)                             as CPU_LOAD_PCT
    ,LOAD                                                 as CPU_LOAD
    ,lpad(' ',ceil(20*load/max(load)over()),'#')          as CPU_GRAPH
    ,LOAD_MAX                                             as CPU_LOAD_MAX
    ,lpad(' ',ceil(20*load_max/max(load_max)over()),'#')  as CPU_MAX_GRAPH
from pivotted
order by
  1,2
/
col cpu_load  clear;
col CPU_GRAPH clear;
col CPU_MAX_GRAPH clear;