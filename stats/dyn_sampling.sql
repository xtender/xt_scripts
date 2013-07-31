col tab_name format a45

with tgr as (
   select 
     s.elapsed_time/1e6   ela_time
    ,regexp_substr(s.sql_text,'FROM ("(\w+?)"."([^"]+?)")',1,1,'i',1) tab
   from v$sqlarea s 
   where 
      s.sql_text like 'SELECT /* OPT_DYN_SAMP */%' 
)
select
   tab           tab_name
  ,sum(ela_time) ela_time
  ,count(*)      cnt
from tgr
group by tgr.tab
order by ela_time desc
/
col tab_name clear
