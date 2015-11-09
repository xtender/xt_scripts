prompt * Event histogram from AWR by masks;
prompt ;
accept waitclass prompt 'Wait class mask[User I/O]: ' default 'User I/O';
accept tmstp1    prompt 'End interval 1[yyyy-mm-dd hh24:mi:ss]: ';
accept tmstp2    prompt 'End interval 2[yyyy-mm-dd hh24:mi:ss]: ';
accept eventmask prompt 'Event mask[%]: ' default '%';

col event_name   for a48 trunc;
col wait_class   for a24 trunc;
break on event_id -
      on event_name -
      on wait_class -
      on e1_wait_count_all -
      on e2_wait_count_all -
      skip 1;

with
 e1 as (
   select event_id
         ,event_name
         ,wait_class
         ,wait_time_milli
         ,wait_count - nvl((select ep.wait_count 
                            from dba_hist_event_histogram ep
                            where ep.dbid            = eh.dbid
                              and ep.instance_number = eh.instance_number
                              and ep.snap_id         = eh.snap_id - 1
                              and ep.event_id        = eh.event_id
                              and ep.wait_time_milli = eh.wait_time_milli
                            ),0) as wait_count
   from dba_hist_event_histogram eh
   where (dbid,instance_number,snap_id) in (select sn.dbid,sn.instance_number,sn.snap_id 
                                            from dba_hist_snapshot sn 
                                            where sn.end_interval_time between timestamp'&tmstp1'
                                                                           and timestamp'&tmstp1' + interval '5' minute
                                           )
     and wait_class like '&waitclass'
     and event_name like '&eventmask'
 )
,e2 as (
   select event_id
         ,event_name
         ,wait_class
         ,wait_time_milli
         ,wait_count - nvl((select ep.wait_count 
                            from dba_hist_event_histogram ep
                            where ep.dbid            = eh.dbid
                              and ep.instance_number = eh.instance_number
                              and ep.snap_id         = eh.snap_id - 1
                              and ep.event_id        = eh.event_id
                              and ep.wait_time_milli = eh.wait_time_milli
                            ),0) as wait_count
   from dba_hist_event_histogram eh
   where (dbid,instance_number,snap_id) in (select sn.dbid,sn.instance_number,sn.snap_id 
                                            from dba_hist_snapshot sn 
                                            where sn.end_interval_time between timestamp'&tmstp2'
                                                                           and timestamp'&tmstp2' + interval '5' minute
                                           )
     and wait_class='User I/O'
     and event_name like '&eventmask'
 )
select nvl(e1.event_id         ,e2.event_id        )     as event_id
      ,nvl(e1.event_name       ,e2.event_name      )     as event_name
      ,nvl(e1.wait_class       ,e2.wait_class      )     as wait_class
      ,sum(nvl(e1.wait_count,0)) over(partition by nvl(e1.event_id,e2.event_id)) as e1_wait_count_all
      ,sum(nvl(e2.wait_count,0)) over(partition by nvl(e1.event_id,e2.event_id)) as e2_wait_count_all
      ,nvl(e1.wait_time_milli  ,e2.wait_time_milli )     as wait_time_milli
      ,nvl(e1.wait_count, 0)                             as e1_wait_count
      ,nvl(e2.wait_count, 0)                             as e2_wait_count
from e1
     full outer join e2
     on  e1.event_id        = e2.event_id
     and e1.wait_time_milli = e2.wait_time_milli
order by wait_class,event_name,wait_time_milli
/
undef waitclass;
undef tmstp1   ;
undef tmstp2   ;
undef eventmask;
clear break;
