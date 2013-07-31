prompt ***************************************
prompt *****   Usage: @stats sid mask    *****
col value   format 999999999999999
col name    format a40
select * 
from v$sesstat st
    ,v$statname sn
where sid=&1
and st.statistic#=sn.STATISTIC#
and sn.name like '%&2%'
/
col value clear
col name clear