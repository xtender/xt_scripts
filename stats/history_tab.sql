accept _owner   prompt "Owner mask[%]: " default '%';
accept _tabname prompt "Table mask[%]: " default '%';

select * 
from dba_tab_stats_history h
where owner like '&_owner'
  and table_name like '&_tabname'
order by h.stats_update_time desc;
undef _owner   ;
undef _tabname ;


