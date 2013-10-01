prompt &_C_REVERSE. *** New density by histograms. &_C_RESET
prompt * Usage: @stats/density_new table [owner]
@inc/input_vars_init;
col owner       format a15;
col table_name  format a20;
col column_name format a20;
col histogram   format a15;
col ep_value    format a15;
select * 
from dba_newdensity 
where owner like nvl(upper('&2'),'%') 
  and table_name like upper('&1');
  
col owner       clear;
col table_name  clear;
col column_name clear;
col histogram   clear;
col ep_value    clear;

@inc/input_vars_undef;