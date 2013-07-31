prompt ***************************************
prompt *****   Usage: @my_stats mask    *****
def mask = %&&1.% 
col value format 999999999999999
select * 
from v$sesstat st
    ,v$statname sn
where sid=sys_context('USERENV','SID')
and st.statistic#=sn.STATISTIC#
and sn.name like '%&mask%'
/
undef mask
undef 1
col value clear