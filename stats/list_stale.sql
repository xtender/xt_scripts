accept _mask prompt "Owner mask[%]: "
select 
   st.OWNER
  ,st.TABLE_NAME
  ,case when count(st.PARTITION_NAME)+count(st.SUBPARTITION_NAME)>0 then 'By partition/subpartition' else 'By table only' end stale_obj
from dba_tab_statistics st
where st.STALE_STATS = 'YES'
and st.owner like nvl(upper('&_mask'),'%')
group by st.OWNER
        ,st.TABLE_NAME
order by 1,2
/
undef _mask
