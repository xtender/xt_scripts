col db_name          new_val _awr_db_name;
select distinct i.dbid, i.db_name
from dba_hist_database_instance i;

accept _awr_db_name     prompt "Enter db_name[&_awr_db_name]: "  default "&_awr_db_name";
accept _awr_beg_time    prompt "Start time[yyyy-mm-dd hh24:mi:ss]: ";
accept _awr_end_time    prompt "End   time[yyyy-mm-dd hh24:mi:ss]: ";
accept _awr_top_n       prompt "Top N[10]: " default 10;
col stext200 for a200;
with 
snaps as (
   select dbid,snap_id
         ,begin_interval_time as beg_time
         ,end_interval_time as end_time
   from dba_hist_snapshot sn
   where dbid in (select distinct dbid from dba_hist_database_instance i where i.db_name='&_awr_db_name') 
     --and snap_id between 63481 and 63504
                         --63490 and 63494
     and end_interval_time between timestamp'&_awr_beg_time' and timestamp'&_awr_end_time'
)
,sql_ordered as (
      select 
        dbid                                                                    as dbid
       ,sql_id                                                                  as sql_id
       ,dense_rank()over(order by sum(elapsed_time_delta) desc)                 as drnk_ela
       ,count(distinct nullif(plan_hash_value,0))                               as plans
       ,count(*)                                                                as snaps
       ,max(snap_id)                                                            as last_snap
       ,count(distinct dbid)                                                    as dbids
       ,sum(executions_delta)                                                   as execs
       ,sum(disk_reads_delta)                                                   as disk_reads
       ,sum(buffer_gets_delta)                                                  as buf_gets
       ,sum(rows_processed_delta)                                               as rows_pr
       ,sum(fetches_delta)                                                      as fetches
       ,sum(elapsed_time_delta/1e6)                                             as ela_time_secs
       ,sum(cpu_time_delta/1e6)                                                 as cpu_time_secs
       ,sum(iowait_delta/1e6)                                                   as io_time_secs
       ,sum(apwait_delta/1e6)                                                   as app_time_secs
       ,round(sum(elapsed_time_delta/1e6)/nullif(sum(executions_delta),0),4)    as elaexe
       ,round(sum(buffer_gets_delta)/nullif(sum(executions_delta),0))           as bufgets_per_exe
      from 
           dba_hist_sqlstat st
           natural join snaps
      group by dbid,sql_id
      order by ela_time_secs desc
)
,topsql as (
    select/*+ no_merge */ so.*
    from sql_ordered so
    where drnk_ela<=&_awr_top_n
)
select
     sql_id
    ,drnk_ela
    ,plans
    ,snaps
    ,last_snap
    ,dbids
    ,execs
    ,disk_reads
    ,buf_gets
    ,rows_pr
    ,fetches
    ,ela_time_secs
    ,cpu_time_secs
    ,io_time_secs
    ,app_time_secs
    ,elaexe
    ,bufgets_per_exe
    ,(select to_char(substr(sql_text,1,200)) from dba_hist_sqltext st where st.sql_id = t.sql_id and st.dbid = t.dbid) as stext200
from topsql t
where rownum>0
/
col stext200  clear;