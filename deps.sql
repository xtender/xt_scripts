@inc/input_vars_init;
select *
from dba_dependencies dd
where dd.referenced_owner like nvl(upper('&2'),'%')
  and dd.referenced_name=upper('&1');
@inc/input_vars_undef;