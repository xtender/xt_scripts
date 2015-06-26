
col db_name         new_val _awr_db_name     for a20;
col beg_date        new_val _awr_db_beg_date noprint;
col end_date        new_val _awr_db_end_date noprint;
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
                       ,to_char(sysdate  ,'yyyy-mm-dd')               as end_date
from (
      select 
        dense_rank()over(partition by dbid,db_name,instance_number order by startup_time desc) n
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

rem ################################################################################################;
rem ################################################################################################;

accept _awr_db_name     prompt "DB name [&_awr_db_name]: "        default "&_awr_db_name";
accept _awr_db_beg_date prompt "Start date [&_awr_db_beg_date]: " default "&_awr_db_beg_date";
accept _awr_db_end_date prompt "End   date [&_awr_db_end_date]: " default "&_awr_db_end_date";
accept _awr_db_beg_hour prompt "Start hour[10]: " default 10;
accept _awr_db_end_hour prompt "End hour[18]: "   default 18;

col metric_name for a35;
col MON for a16;
col TUE for a16;
col WED for a16;
col THU for a16;
col FRI for a16;
col SAT for a16;
col SUN for a16;


with
 dbids as (
    select distinct i.dbid, i.db_name
    from dba_hist_database_instance i
    where upper(db_name) like upper('&_awr_db_name')
 )
,snaps as (
    select dbids.db_name, sn.dbid, sn.snap_id
         , sn.begin_interval_time as beg_time
         , sn.end_interval_time   as end_time
         , extract(hour from sn.begin_interval_time) beg_hh
         , extract(hour from sn.end_interval_time)   end_hh
    from dbids, dba_hist_snapshot sn
    where dbids.dbid = sn.dbid
      and sn.end_interval_time   >= date'&_awr_db_beg_date'
      and sn.begin_interval_time <  date'&_awr_db_end_date' +1
)
select 
     metric_name
    ,to_char(avg(decode(to_char(beg_time,'DY','nls_date_language=english'),'MON',average)),'9g999999990d990') as MON
    ,to_char(avg(decode(to_char(beg_time,'DY','nls_date_language=english'),'TUE',average)),'9g999999990d990') as TUE
    ,to_char(avg(decode(to_char(beg_time,'DY','nls_date_language=english'),'WED',average)),'9g999999990d990') as WED
    ,to_char(avg(decode(to_char(beg_time,'DY','nls_date_language=english'),'THU',average)),'9g999999990d990') as THU
    ,to_char(avg(decode(to_char(beg_time,'DY','nls_date_language=english'),'FRI',average)),'9g999999990d990') as FRI
    ,to_char(avg(decode(to_char(beg_time,'DY','nls_date_language=english'),'SAT',average)),'9g999999990d990') as SAT
    ,to_char(avg(decode(to_char(beg_time,'DY','nls_date_language=english'),'SUN',average)),'9g999999990d990') as SUN
from snaps sn
    ,dba_hist_sysmetric_summary sm
where sn.dbid    = sm.dbid
  and sn.snap_id = sm.snap_id
  --and lower(metric_name) not like '%per txn'
  and end_hh >= &_awr_db_beg_hour
  and beg_hh <= &_awr_db_end_hour
  and metric_name in (
           'Average Active Sessions'
          ,'Buffer Cache Hit Ratio'
          ,'Cursor Cache Hit Ratio'
          ,'Library Cache Hit Ratio'
          ,'Database CPU Time Ratio'
          ,'Host CPU Utilization (%)'
          ,'DB Block Changes Per Sec'
          ,'Executions Per Sec'
          ,'I/O Megabytes per Second'
          ,'Physical Read Total Bytes Per Sec'
          ,'Physical Write Total Bytes Per Sec'
          ,'Redo Generated Per Sec'
          ,'SQL Service Response Time'
         )
group by metric_name
order by metric_name
/
clear col;
