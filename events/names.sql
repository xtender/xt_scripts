select distinct wait_class#,wait_class from v$event_name order by 1;
accept _wait_class  prompt 'Enter wait_class#[default=all]:';
accept _mask        prompt 'Enter mask[default=%]:' default '%';

col event_name      format a40;
col parameter1      format a15;
col parameter2      format a15;
col parameter3      format a15;
col wait_class_id   noprint;
col wait_class#     noprint;

select 
     event#
     ,event_id
     ,name as event_name
     ,parameter1
     ,parameter2
     ,parameter3
     ,wait_class_id
     ,wait_class#
     ,wait_class
from v$event_name e 
where 
     e.wait_class#=nvl('&_wait_class'+0,e.wait_class#)
 and upper(e.NAME) like upper('&_mask%');
 
col event_name      clear;
col parameter1      clear;
col parameter2      clear;
col parameter3      clear;
col wait_class_id   clear;
col wait_class#     clear;