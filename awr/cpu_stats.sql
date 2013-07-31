with 
 awr_grp_stats as (
      select   
             dbtime1.snap_id
            ,dbtime1.stat_name
            ,dbtime2.value-dbtime1.value as delta
      from dba_hist_sys_time_model       dbtime1
          ,dba_hist_sys_time_model       dbtime2
      where
            dbtime1.dbid            = 3126056015
        and dbtime1.instance_number = 1
        and dbtime1.stat_id        in (
                                       3649082374  --DB time
                                      ,2821698184  --sql execute elapsed time
                                      ,2748282437  --DB CPU
                                      ,4157170894   --background elapsed time
                                      ,2643905994   --PL/SQL execution elapsed time
                                      ,2451517896   --background cpu time
                                      )
        
        and dbtime2.dbid            = dbtime1.dbid
        and dbtime2.instance_number = dbtime1.instance_number
        and dbtime2.stat_id         = dbtime1.stat_id 
        and dbtime2.snap_id         = dbtime1.snap_id+1
        and dbtime2.value           > dbtime1.value
 )
,awr_stats as (
   select *
   from awr_grp_stats
   pivot (
      sum(delta)
      for stat_name in (
               'DB time'                       as "DB time"
              ,'sql execute elapsed time'      as "SQL ela.time"
              ,'DB CPU'                        as "DB CPU"
              ,'background elapsed time'       as "Background ela.time"
              ,'PL/SQL execution elapsed time' as "PL/SQL ela.time"
              ,'background cpu time'           as "Background cpu"
     )
   )
)   ------------------
select trunc(sn.begin_interval_time,'hh') dt
      ,s."DB time"
      ,s."SQL ela.time"
      ,s."DB CPU"
        ,round(100*s."DB CPU" / 1e6 /
               (
                60*60*(select p.value from dba_hist_parameter p 
                       where p.parameter_name  = 'cpu_count' 
                         and p.dbid            = sn.dbid 
                         and p.snap_id         = sn.snap_id 
                         and p.instance_number = sn.instance_number
                     )
               )
              ) "DB cpu pct"
      ,s."Background ela.time"
      ,s."PL/SQL ela.time"
      ,s."Background cpu"
from dba_hist_snapshot sn
    ,awr_stats s
where 
      sn.dbid            = 3126056015
  and sn.instance_number = 1
  and sn.snap_id         = s.snap_id
--  and to_number(to_char(sn.begin_interval_time,'dd')) between 1 and 5
  and to_number(to_char(sn.begin_interval_time,'hh24'))=9-- between 8 and 10
  and round(100*s."DB CPU" / 1e6 /
               (
                60*60*(select p.value from dba_hist_parameter p 
                       where p.parameter_name  = 'cpu_count' 
                         and p.dbid            = sn.dbid 
                         and p.snap_id         = sn.snap_id 
                         and p.instance_number = sn.instance_number
                     )
               )
           )>40
order by 1 desc,2 desc
/
