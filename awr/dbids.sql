col db_name         for a20;
col version         for a12;
col instance_name   for a20;
col host_name       for a30;
col platform_name   for a30;
col last_startup    for a19;

select 
                        dbid, db_name, version, instance_name, host_name
&_IF_ORA11_OR_HIGHER   ,platform_name
                       ,to_char(startup_time,'yyyy-mm-dd hh24:mi:ss') as last_startup
from (
      select 
        dense_rank()over(partition by dbid,db_name,version order by startup_time desc) n
       ,i.*
      from dba_hist_database_instance i
)
where n=1
order by startup_time;

col db_name         clear;
col version         clear;
col instance_name   clear;
col host_name       clear;
col platform_name   clear;
col last_startup    clear;
