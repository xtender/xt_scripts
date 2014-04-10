prompt ***************************************
prompt *****   Usage: @my_stats mask    *****
def mask = %&&1.% 
col name  format a50;
col value format 999999999999999;
select name,value 
from v$mystat st
    ,v$statname sn
where st.statistic#=sn.STATISTIC#
  and sn.name like '&mask'
/
col name  clear;
col value clear;
undef mask;
undef 1;