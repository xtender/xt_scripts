@inc/input_vars_init;
prompt **************************************************************************;
prompt * Top N events by AWR snap
prompt *

set termout off;
col dt_beg   new_val   dt_beg noprint;
col dt_end   new_val   dt_end noprint;
select to_char(trunc(sysdate-5),'yyyy-mm-dd hh24:mi:ss') dt_beg
      ,to_char(trunc(sysdate  ),'yyyy-mm-dd hh24:mi:ss') dt_end
from dual;
set termout on;

accept dt_beg prompt "Date start[&dt_beg]: " default '&dt_beg';
accept dt_end prompt "Date end  [&dt_end]: " default '&dt_end';
accept hh_beg prompt "Hours start[10]: " default 10;
accept hh_end prompt "Hours end  [18]: " default 18;
accept _mask prompt "Metric mask[phy.*(read|write).*sec]: " default 'phy.*(read|write).*sec';

accept _avg prompt "Show avg(y/n)[Y] :" default "y";
accept _min prompt "Show min(y/n)[N] :" default "n";
accept _max prompt "Show max(y/n)[N] :" default "n";

col _avg new_val _avg noprint;
col _min new_val _min noprint;
col _max new_val _max noprint;

select
  case when lower('&_avg')='y' then '' else '--' end "_avg"
 ,case when lower('&_min')='y' then '' else '--' end "_min"
 ,case when lower('&_max')='y' then '' else '--' end "_max"
from dual;

col d_day  for a10 heading "DAY";
col d_time for a13 heading "TIME";
break on inst_id on d_day skip 1;

col metric_0_averag for a22 WORD_WRAP;
col metric_1_averag for a22 WORD_WRAP;
col metric_2_averag for a22 WORD_WRAP;
col metric_3_averag for a22 WORD_WRAP;
col metric_4_averag for a22 WORD_WRAP;
col metric_5_averag for a22 WORD_WRAP;
col metric_6_averag for a22 WORD_WRAP;
col metric_7_averag for a22 WORD_WRAP;
col metric_8_averag for a22 WORD_WRAP;
col metric_9_averag for a22 WORD_WRAP;

col metric_0_minval for a22 WORD_WRAP;
col metric_1_minval for a22 WORD_WRAP;
col metric_2_minval for a22 WORD_WRAP;
col metric_3_minval for a22 WORD_WRAP;
col metric_4_minval for a22 WORD_WRAP;
col metric_5_minval for a22 WORD_WRAP;
col metric_6_minval for a22 WORD_WRAP;
col metric_7_minval for a22 WORD_WRAP;
col metric_8_minval for a22 WORD_WRAP;
col metric_9_minval for a22 WORD_WRAP;

col metric_0_maxval for a22 WORD_WRAP;
col metric_1_maxval for a22 WORD_WRAP;
col metric_2_maxval for a22 WORD_WRAP;
col metric_3_maxval for a22 WORD_WRAP;
col metric_4_maxval for a22 WORD_WRAP;
col metric_5_maxval for a22 WORD_WRAP;
col metric_6_maxval for a22 WORD_WRAP;
col metric_7_maxval for a22 WORD_WRAP;
col metric_8_maxval for a22 WORD_WRAP;
col metric_9_maxval for a22 WORD_WRAP;

with 
 sm as (
   select--+ materialize
         sm.dbid
        ,sm.snap_id
        ,sm.instance_number as inst_id
        ,sm.begin_time      as beg_time
        ,sm.end_time
        ,sm.metric_id
        ,sm.metric_name
        ,sm.metric_unit
        ,dense_rank()over(partition by dbid,snap_id,instance_number order by metric_id) n
        ,dense_rank()over(order by snap_id) snap#
&_avg   ,'|'||to_char(round(sm.average ,3),'999g999g999g990d000') as averag
&_min   ,'|'||to_char(round(sm.minval  ,3),'999g999g999g990d000') as minval 
&_max   ,'|'||to_char(round(sm.maxval  ,3),'999g999g999g990d000') as maxval 
&_avg   ,max(length(to_char(round(sm.average ,3),'tm9'))) over(partition by metric_id)  as l_average
&_min   ,max(length(to_char(round(sm.minval  ,3),'tm9'))) over(partition by metric_id)  as l_minval 
&_max   ,max(length(to_char(round(sm.maxval  ,3),'tm9'))) over(partition by metric_id)  as l_maxval 
   from dba_hist_sysmetric_summary sm
   where 1=1
     and (dbid,snap_id) in 
                    (select sn.dbid,sn.snap_id 
                     from dba_hist_snapshot sn
                     where 
                           timestamp'&dt_beg' <= end_interval_time
                       and timestamp'&dt_end' >= begin_interval_time
                       and (
                         extract(hour from begin_interval_time) between &hh_beg and &hh_end
                         or
                         extract(hour from   end_interval_time) between &hh_beg and &hh_end
                       )
                    )
     and regexp_like(metric_name,q'[&_mask]','i')
 ) 
,header as (
   select 
       cast(null as number) inst_id
      ,'' d_day
      ,'' d_time
      ,cast(null as number) snap_id
&_avg      ,max(decode(n, 1 , metric_name)) metric_0_averag
&_min      ,max(decode(n, 1 , metric_name)) metric_0_minval
&_max      ,max(decode(n, 1 , metric_name)) metric_0_maxval
&_avg      ,max(decode(n, 2 , metric_name)) metric_1_averag
&_min      ,max(decode(n, 2 , metric_name)) metric_1_minval
&_max      ,max(decode(n, 2 , metric_name)) metric_1_maxval
&_avg      ,max(decode(n, 3 , metric_name)) metric_2_averag
&_min      ,max(decode(n, 3 , metric_name)) metric_2_minval
&_max      ,max(decode(n, 3 , metric_name)) metric_2_maxval
&_avg      ,max(decode(n, 4 , metric_name)) metric_3_averag
&_min      ,max(decode(n, 4 , metric_name)) metric_3_minval
&_max      ,max(decode(n, 4 , metric_name)) metric_3_maxval
&_avg      ,max(decode(n, 5 , metric_name)) metric_4_averag
&_min      ,max(decode(n, 5 , metric_name)) metric_4_minval
&_max      ,max(decode(n, 5 , metric_name)) metric_4_maxval
&_avg      ,max(decode(n, 6 , metric_name)) metric_5_averag
&_min      ,max(decode(n, 6 , metric_name)) metric_5_minval
&_max      ,max(decode(n, 6 , metric_name)) metric_5_maxval
&_avg      ,max(decode(n, 7 , metric_name)) metric_6_averag
&_min      ,max(decode(n, 7 , metric_name)) metric_6_minval
&_max      ,max(decode(n, 7 , metric_name)) metric_6_maxval
&_avg      ,max(decode(n, 8 , metric_name)) metric_7_averag
&_min      ,max(decode(n, 8 , metric_name)) metric_7_minval
&_max      ,max(decode(n, 8 , metric_name)) metric_7_maxval
&_avg      ,max(decode(n, 9 , metric_name)) metric_8_averag
&_min      ,max(decode(n, 9 , metric_name)) metric_8_minval
&_max      ,max(decode(n, 9 , metric_name)) metric_8_maxval
&_avg      ,max(decode(n,10 , metric_name)) metric_9_averag
&_min      ,max(decode(n,10 , metric_name)) metric_9_minval
&_max      ,max(decode(n,10 , metric_name)) metric_9_maxval
   from sm
   where snap#=1
)
,vals as (
   select
       inst_id
      ,to_char(beg_time,'yyyy-mm-dd') d_day
      ,to_char(beg_time,'hh24:mi') 
         ||' - ' ||
       to_char(end_time,'hh24:mi')    d_time
      ,snap_id
&_avg      ,max(decode(n, 1 , averag)) metric_0_averag
&_min      ,max(decode(n, 1 , minval)) metric_0_minval
&_max      ,max(decode(n, 1 , maxval)) metric_0_maxval
&_avg      ,max(decode(n, 2 , averag)) metric_1_averag
&_min      ,max(decode(n, 2 , minval)) metric_1_minval
&_max      ,max(decode(n, 2 , maxval)) metric_1_maxval
&_avg      ,max(decode(n, 3 , averag)) metric_2_averag
&_min      ,max(decode(n, 3 , minval)) metric_2_minval
&_max      ,max(decode(n, 3 , maxval)) metric_2_maxval
&_avg      ,max(decode(n, 4 , averag)) metric_3_averag
&_min      ,max(decode(n, 4 , minval)) metric_3_minval
&_max      ,max(decode(n, 4 , maxval)) metric_3_maxval
&_avg      ,max(decode(n, 5 , averag)) metric_4_averag
&_min      ,max(decode(n, 5 , minval)) metric_4_minval
&_max      ,max(decode(n, 5 , maxval)) metric_4_maxval
&_avg      ,max(decode(n, 6 , averag)) metric_5_averag
&_min      ,max(decode(n, 6 , minval)) metric_5_minval
&_max      ,max(decode(n, 6 , maxval)) metric_5_maxval
&_avg      ,max(decode(n, 7 , averag)) metric_6_averag
&_min      ,max(decode(n, 7 , minval)) metric_6_minval
&_max      ,max(decode(n, 7 , maxval)) metric_6_maxval
&_avg      ,max(decode(n, 8 , averag)) metric_7_averag
&_min      ,max(decode(n, 8 , minval)) metric_7_minval
&_max      ,max(decode(n, 8 , maxval)) metric_7_maxval
&_avg      ,max(decode(n, 9 , averag)) metric_8_averag
&_min      ,max(decode(n, 9 , minval)) metric_8_minval
&_max      ,max(decode(n, 9 , maxval)) metric_8_maxval
&_avg      ,max(decode(n,10 , averag)) metric_9_averag
&_min      ,max(decode(n,10 , minval)) metric_9_minval
&_max      ,max(decode(n,10 , maxval)) metric_9_maxval
   from sm
   group by 
       snap_id
      ,inst_id
      ,beg_time
      ,end_time
   order by 1,2,3,4
)
select 
   h.* 
from header h
union all
select * 
from vals
/
undef _avg _min _max;
undef dt_beg dt_end hh_beg hh_end _mask;
                    
@inc/input_vars_undef;
