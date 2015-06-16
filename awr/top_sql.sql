col db_name          new_val _awr_db_name;
select distinct i.dbid, i.db_name
from dba_hist_database_instance i;

accept _awr_db_name     prompt "Enter db_name[&_awr_db_name]: "  default "&_awr_db_name";
accept _awr_beg_time    prompt "Start time[yyyy-mm-dd hh24:mi:ss]: ";
accept _awr_end_time    prompt "End   time[yyyy-mm-dd hh24:mi:ss]: ";
accept _awr_top_n       prompt "Top N[10]: " default 10;
with 
snaps as (
   select dbid,snap_id
         ,begin_interval_time as beg_time
         ,end_interval_time as end_time
   from dba_hist_snapshot sn
   where dbid=(select distinct dbid from dba_hist_database_instance i where i.db_name='&_awr_db_name') 
     --and snap_id between 63481 and 63504
                         --63490 and 63494
     and end_interval_time between timestamp'&_awr_beg_time' and timestamp'&_awr_end_time'
)
,topsql as (
      select 
        sql_id
       ,dense_rank()over(order by sum(elapsed_time_delta) desc) drnk_ela
       ,count(distinct plan_hash_value) as plans
       ,count(*)                        as snaps
       ,max(snap_id)                    as last_snap
       ,count(distinct dbid)            as dbids
       ,sum(executions_delta)           as execs
       ,sum(disk_reads_delta)           as disk_reads
       ,sum(buffer_gets_delta)          as buf_gets
       ,sum(rows_processed_delta)       as rows_pr
       ,sum(elapsed_time_delta/1e6)     as ela_time_secs
       ,sum(cpu_time_delta/1e6)         as cpu_time_secs
       ,sum(iowait_delta/1e6)           as io_time_secs
       ,sum(apwait_delta/1e6)           as app_time_secs
       ,round(sum(elapsed_time_delta/1e6)/nullif(sum(executions_delta),0),4) as elaexe
       ,round(sum(buffer_gets_delta)/nullif(sum(executions_delta),0))      as bufgets_per_exe
      from 
           dba_hist_sqlstat st
           natural join snaps
      group by sql_id
      order by ela_time_secs desc
)
select *
from topsql
where drnk_ela<=&_awr_top_n
/
