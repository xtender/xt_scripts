prompt ***************************************
prompt *****   Usage: @stats sid mask    *****
@inc/input_vars_init;
col value   format 999999999999999
col name    format a40

accept _sid  prompt "Enter sid[&1]: "     default "&1";
accept _mask prompt "Statname mask[&2](simple): " default "&2";
select * 
from v$sesstat st
    ,v$statname sn
where sid=&_sid
and st.statistic#=sn.STATISTIC#
and lower(sn.name) like lower('&_mask')
/
col value   clear;
col name    clear;
undef _mask _sid;
@inc/input_vars_undef;