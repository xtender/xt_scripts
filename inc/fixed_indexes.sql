@inc/input_vars_init;

select * 
from v$indexed_fixed_column
where table_name=upper('&1');

@inc/input_vars_undef;