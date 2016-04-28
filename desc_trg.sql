col owner               for a30;
col trigger_name        for a30;
col trigger_type        for a12;
col triggering_event    for a30;
col table_owner         for a30;
col base_object_type    for a5;
col column_name         for a30;
col when_clause         for a30;

col description         for a30;

col trigger_body new_val trigger_body noprint;

break on owner on trigger_name skip page;
ttitle  -
   '###############################################################################' skip 1 -
   '' trigger_body skip 1 -
   '###############################################################################' skip 1 -
   '' skip 2;
select
 tr.owner
,tr.trigger_name
,tr.trigger_type
,tr.triggering_event
,tr.table_owner
,tr.base_object_type
,tr.column_name
,tr.when_clause
,tr.status
,tr.description
,tr.action_type
,tr.trigger_body
from dba_triggers tr 
where 
   tr.trigger_name='MI_MOD_CTX_TRIG'
/
