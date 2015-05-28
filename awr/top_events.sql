prompt **************************************************************************;
prompt * Top N events by AWR snap
prompt *

set termout off;
col date_start new_val date_start noprint;
col date_end   new_val date_end   noprint;
select to_char(sysdate-5,'yyyy-mm-dd') date_start
      ,to_char(sysdate  ,'yyyy-mm-dd') date_end
from dual;
set termout on;

accept date_start prompt "Date start[&date_start]: " default '&date_start';
accept date_end   prompt "Date end  [&date_end]: "   default '&date_end';
accept hh_start   prompt "Hours filter start[00]: " default '00';
accept hh_end     prompt "Hours filter end  [23]: " default '23';
accept top_n      prompt "Top N[5]: " default 5;
accept inst_id    prompt "Instance_ID[empty for all]: ";


col beg_time    for a16;
col end_time    for a16;
col wait_class  for a20;
col event_name  for a40 trunc;
col time_waited for a16;
break on dbid on snap_id on beg_time on end_time on inst_id skip 1;

with 
snaps as (
     select *
     from (
        select sn.dbid,sn.snap_id,sn.instance_number
             , begin_interval_time as beg_time
             ,   end_interval_time as end_time
        from dba_hist_snapshot sn
        where sn.end_interval_time   >= date'&date_start'
          and sn.begin_interval_time <  date'&date_end'+1
          and sn.instance_number      = nvl(to_number('&inst_id'),sn.instance_number)
        order by sn.end_interval_time desc
     )
     --where rownum<=5
)
,waits_and_cpu as (
    select
       dbid,snap_id,instance_number
      ,beg_time
      ,end_time
      ,wait_class
      ,event_name
      ,time_waited_micro
      ,lag(time_waited_micro) over(partition by dbid,instance_number,wait_class,event_name order by snap_id) as time_waited_micro_prev
    from snaps
         join dba_hist_system_event e using(dbid,snap_id,instance_number)
    where e.wait_class!='Idle'
  union all
    select
      dbid,snap_id,instance_number
     ,beg_time
     ,end_time
     ,'DB CPU' as wait_class
     ,'DB CPU' as event_name
     ,value    as time_waited_micro
     ,lag(value)over(partition by dbid,instance_number order by snap_id)  time_waited_micro_prev 
   from snaps
        join DBA_HIST_SYS_TIME_MODEL m using(dbid,snap_id,instance_number)
   where stat_name =('DB CPU')
)
,events as (
   select 
      dbid,snap_id,instance_number
     ,beg_time
     ,end_time
     ,wait_class
     ,event_name
     ,case when time_waited_micro < time_waited_micro_prev then null -- db restarted or number overflow
           else time_waited_micro - time_waited_micro_prev
      end time_waited_micro
   from waits_and_cpu
   where time_waited_micro_prev is not null
     and (
          extract(hour from beg_time) between &hh_start and &hh_end
          or
          extract(hour from end_time) between &hh_start and &hh_end
         )
)
,top_events as (
   select dbid
         ,snap_id
         ,to_char(beg_time,'yyyy-mm-dd hh24:mi') beg_time
         ,to_char(end_time,'yyyy-mm-dd hh24:mi') end_time
         ,instance_number inst_id
         , n, wait_class, event_name, time_waited_micro
   from (
        select 
              row_number()over(partition by dbid,snap_id,instance_number order by time_waited_micro desc) N
             ,e.*
        from events e
   )
   where N <= &top_n
)
select dbid
      ,snap_id
      ,beg_time
      ,end_time
      ,inst_id, n, wait_class, event_name
      ,to_char(round(time_waited_micro/1e6),'999g999g999g999') as time_waited
from top_events
order by dbid, snap_id desc, inst_id, n
/
clear break;
col beg_time    clear;
col end_time    clear;
col wait_class  clear;
col event_name  clear;
col time_waited clear;
undef date_start;
undef date_end  ;
undef hh_start  ;
undef hh_end    ;
undef top_n     ;
undef inst_id   ;
