@inc/input_vars_init;

col OWNER                   format a30;
col NAME                    format a30;
col TYPE                    format a12;
col REFERENCED_OWNER        format a30 heading REF_OWNER;
col REFERENCED_NAME         format a30 heading REF_NAME;
col REFERENCED_TYPE         format a12 heading REF_TYPE;
col REFERENCED_LINK_NAME    format a10 heading REF_LINK;
col DEPENDENCY_TYPE         format a10;

select *
from dba_dependencies dd
where dd.referenced_owner like nvl(upper('&2'),'%')
  and dd.referenced_name=upper('&1');

col OWNER                   clear;
col NAME                    clear;
col TYPE                    clear;
col REFERENCED_OWNER        clear;
col REFERENCED_NAME         clear;
col REFERENCED_TYPE         clear;
col REFERENCED_LINK_NAME    clear;
col DEPENDENCY_TYPE         clear;

@inc/input_vars_undef;
