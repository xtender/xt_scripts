select owner,count(*) 
from dba_tab_statistics st 
where st.STALE_STATS='YES'
group by owner
order by 2 desc
/