@inc/input_vars_init;

col owner       for a30;
col table_name  for a20 head "TABLE"
col column_name for a30 head "COLUMN"

select 
   owner, 
   table_name, 
   column_name, 
   num_distinct, 
--   low_value, 
--   high_value, 
--   density, 
   num_nulls, 
   num_buckets, 
   last_analyzed, 
--   sample_size, 
   global_stats, 
   user_stats, 
   avg_col_len, 
   histogram
from dba_tab_col_statistics st 
where 
   ('&3' is not null 
      and st.owner       like upper('&1') 
      and st.table_name  like upper('&2')
      and st.column_name like upper('&3')
   )
   or
   ('&3' is null 
      and st.table_name  like upper('&1')
      and st.column_name like upper('&2')
   )
/
col owner       clear;
col table_name  clear;
col column_name clear;
@inc/input_vars_undef;
