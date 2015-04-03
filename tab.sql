@inc/input_vars_init;

col owner       for a30;
col table_name  for a30;
col partitioned for a4 head 'PART';
col temporary   for a4 head 'TEMP';
col iot_type    for a8;

select 
   t.owner
  ,t.table_name
  ,t.partitioned
  ,t.temporary
  ,(select created from all_objects o where o.owner=t.owner and o.object_name=t.table_name and o.object_type='TABLE') as created
  ,t.IOT_TYPE
  ,t.last_analyzed
  ,t.num_rows
  ,t.blocks
from all_tables t
where upper(t.table_name) like upper('&1')
  and t.owner             like upper(nvl('&2','%'))
order by 1,2
/
col owner       clear;
col table_name  clear;
col partitioned clear;
col temporary   clear;
col iot_type    clear;

@inc/input_vars_undef;
