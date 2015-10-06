prompt *** Event names by masks
prompt * Usage @event_names event_name_mask [wait_class#]
select distinct wait_class#,wait_class from v$event_name order by 1;
accept _wait_class prompt 'Enter wait_class#[default=all]:';
select * 
from v$event_name e 
where 
    e.wait_class#=nvl('&_wait_class'+0,e.wait_class#)
 and upper(e.NAME) like upper('&1');
