prompt ***************************************
prompt *****   Usage: @stats sid mask    *****
@inc/input_vars_init;
col value   format 999999999999999
col name    format a40

accept _sid  prompt "Enter sid: ";
accept _mask prompt "Statname mask: ";
select * 
from v$sesstat st
    ,v$statname sn
where sid=&_sid
and st.statistic#=sn.STATISTIC#
and sn.name like '&_mask'
/
col value   clear;
col name    clear;
undef _mask _sid;
@inc/input_vars_undef;