@inc/input_vars_init;
set feed on;

select 
    decode(tc.COLUMN_ID,1,' ',',')
  ||tc.column_name col
from dba_tab_columns tc
where tc.owner like nvl(upper('&2'),'%')
  and tc.table_name like upper('&1')
order by tc.COLUMN_ID;
@inc/input_vars_undef;
