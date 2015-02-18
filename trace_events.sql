prompt *** Find trace event by mask: ;
accept _mask prompt "Event mask[%]: " default '%';
col description for a100;

with v as (
  select id trace_event, sys.standard.sqlerrm(id) description
  from xmltable('-19999 to -10000' columns id int path '.') ids
 )
select *
from v
where description not like '%Message % not found;%'
  and lower(description) like lower('&_mask')
order by trace_event desc
/
undef _mask
col description clear;
