accept _owner_mask prompt "Owner mask[%]: " default '%';
accept _index_mask prompt "Index mask[%]: " default '%';
accept _table_mask prompt "Table mask[%]: " default '%';

col idx_owner   for a30;
col idx_name    for a30;
col idx_table   for a30;
col idx_status  for a20;

select idx_owner,idx_name,idx_table,idx_status 
from ctxsys.ctx_indexes
where idx_owner like '&_owner_mask'
  and idx_name  like '&_index_mask'
  and idx_table like '&_table_mask'
;
col idx_owner   clear;
col idx_name    clear;
col idx_table   clear;
col idx_status  clear;
