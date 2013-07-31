col name format a50
select sn.name,st.value
from v$sesstat st
    ,v$statname sn
where st.sid=&1
  and st.STATISTIC#=sn.STATISTIC#
  and upper(sn.name) like '%PGA%'
/
col name clear