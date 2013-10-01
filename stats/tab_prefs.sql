@inc/input_vars_init;
col PREFERENCE_NAME  format a25
col PREFERENCE_VALUE format a100
select * 
from dba_tab_stat_prefs 
where table_name=upper('&1')
  and owner like nvl(upper('&2'),'%')
order by 1,2,3
/
@inc/input_vars_undef;