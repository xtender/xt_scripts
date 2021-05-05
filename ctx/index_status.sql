@inc/input_vars_init.sql

prompt &_C_REVERSE. *** Indexes: index_name like '&1' and owner like nvl(upper('&2'),'%') &_C_RESET

col owner       for a30;
col idx_name    for a30;
col idx_table   for a30;
col idx_status  for a20;

select 
   idx_owner as owner
  ,idx_name
  ,idx_table
  ,idx_status 
from ctxsys.ctx_indexes
where idx_owner like nvl(upper('&2'),'%')
  and idx_name  like upper('&1')
;
col status          for a10;
col DOMIDX_STATUS   for a15;
col DOMIDX_OPSTATUS for a15;
col FUNCIDX_STATUS  for a15;
col DROPPED         for a7;


select 
  owner,
  index_name as idx_name,
  status,
  DOMIDX_STATUS,
  DOMIDX_OPSTATUS,
  FUNCIDX_STATUS,
  DROPPED 
from dba_indexes idx
where idx.owner       like nvl(upper('&2'),'%')
  and idx.index_name  like upper('&1')
;

col owner       clear;
col idx_name    clear;
col idx_table   clear;
col idx_status  clear;

