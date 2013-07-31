@inc/input_vars_init;

break on trigger_name page
col trigger_name        format a30
col action_type         format a12
col trigger_type        format a20
col triggering_event    format a30
col trigger_body        format a150

select 
     dba_triggers.trigger_name
    ,dba_triggers.action_type
    ,dba_triggers.trigger_type
    ,dba_triggers.triggering_event 
    ,dba_triggers.trigger_body 
from dba_triggers 
where 
   table_name=upper('&1')
   and table_owner = nvl(upper('&2'),table_owner);

col trigger_name        clear;
col action_type         clear;
col trigger_type        clear;
col triggering_event    clear;
col trigger_body        clear;
