
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

rem ################################################################################################;
rem ################################################################################################;

accept _awr_db_name     prompt "DB name [&_awr_db_name]: "        default "&_awr_db_name";
accept _awr_db_beg_date prompt "Start date [&_awr_db_beg_date]: " default "&_awr_db_beg_date";

prompt Popular masks:;
prompt *   DB time;
prompt *   DB CPU;
prompt *   db block changes;
prompt *   sql execute elapsed time;
prompt ;
accept stat_mask prompt "Enter stat_name mask[DB time]: " default "DB time";

rem ################################################################################################;
rem ################################################################################################;

col services_stats new_val services_stats noprint;
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
      and sn.end_interval_time>date'&_awr_db_beg_date'
      and rownum=1
)
select
  listagg(st.service_name
          ,', '
         )
  within group(order by value desc) services
  /*
 ,listagg(q'[,to_char(sum(decode(st.service_name,']'
               ||st.service_name
          ||q'[',st.value)),'9g999g999d0', 'NLS_NUMERIC_CHARACTERS = ''. ''') as "]'||st.service_name||'"'
           ,chr(10)
         ) */
 ,listagg(',round(sum(decode(st.service_name,'''||st.service_name||''',st.value))) as "'||st.service_name||'"'
           ,chr(10)
         )
  within group(order by value desc) services_stats
from snaps sn, dba_hist_service_stat st
where sn.dbid    = st.dbid
  and sn.snap_id = st.snap_id
  and st.stat_name in ('DB time')
/
rem ################################################################################################;
rem ################################################################################################;
col snap_id    for 99999999;
col day        for a16;
col hh         for a2;
col snap_min   for 99999999;
col snap_max   for 99999999;
col snaps      for 99999;
col stat_name  for a30 trunc;
col pct        for a20;

break on day skip 1;

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
      and sn.instance_number = 1
      and sn.end_interval_time>date'&_awr_db_beg_date'
)
,service_stats as (
    select * 
    from (
       select
           sn.db_name
          ,sn.beg_time
          ,sn.snap_id
          ,st.service_name
          ,st.stat_name
          , (st.value 
              - 
             lag(st.value) 
                 over(
                     partition by st.dbid,st.instance_number,st.service_name_hash,st.service_name,st.stat_id,st.stat_name 
                     order by st.snap_id
                 )
            )/1e6 as value
       from snaps sn
           ,dba_hist_service_stat st
       where sn.dbid    = st.dbid
         and sn.snap_id = st.snap_id
         and st.stat_name like q'[&stat_mask]'
    ) vst
    where vst.value is not null
)
select 
     --sn.db_name,
     to_char(trunc(beg_time,'hh24'),'yyyy-mm-dd DY') as day
    ,to_char(trunc(beg_time,'hh24'),'hh24'      ) as hh
    ,min(snap_id)                                 as snap_min
    ,max(snap_id)                                 as snap_max
    ,count(distinct snap_id)                      as snaps
    ,stat_name                                    as stat_name
  &services_stats
    , to_char(ceil(100*sum(value)/max(sum(value))over(partition by stat_name)),'999')||' % '
     || rpad(rpad('['
                 , 1+ceil(10*sum(value)/max(sum(value))over(partition by stat_name))
                 , '#'
                 )
             ,12
             ,' '
            )
        ||']' 
         as pct

from service_stats st
group by
     db_name
    ,trunc(beg_time,'hh24')
    ,stat_name
order by
     db_name
    ,trunc(beg_time,'hh24')
    ,stat_name
/
clear col;
clear break;
