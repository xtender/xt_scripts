col load for 9990d9;
select 
     inst_id
    ,max(decode(stat_name,'LOAD'    ,value)) load
    ,max(decode(stat_name,'NUM_CPUS',value)) num_cpus 
from GV$OSSTAT 
where stat_name in ('LOAD','NUM_CPUS')
group by inst_id
order by inst_id;
col load clear;