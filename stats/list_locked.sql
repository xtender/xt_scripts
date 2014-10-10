@inc/input_vars_init;
col temporary for a4;
break on stale page;
select 
       nvl(st.stale_stats,'N/A') as stale
      ,st.owner
      ,st.table_name
      ,min(st.last_analyzed) min_last_analyzed
      ,t.temporary
      ,t.nested
from dba_tab_statistics st 
    ,dba_tables t
where st.stattype_locked is not null
  and st.owner like nvl(upper('&1'),'%')
  and t.owner      = st.owner
  and t.table_name = st.table_name
group by 
      st.stale_stats
     ,st.owner
     ,st.table_name
     ,t.temporary
     ,t.nested
order by decode(stale_stats,null,1,'YES',2,'NO',3)
        ,st.owner
        ,st.table_name
/
col temporary clear;
@inc/input_vars_undef;
clear break;
