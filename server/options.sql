col o_enabled   for a80 head "Enabled options:";
col o_disabled  for a80 head "Disabled options:";
col value       for a12;

prompt &_C_RED. ============================================================ &_C_RESET.;
select o.parameter as o_enabled 
from v$option o
where o.value='TRUE'
order by 1;

prompt &_C_RED. ============================================================ &_C_RESET.;
select o.parameter as "Disabled options:"
from v$option o
where o.value='FALSE'
order by 1;

prompt &_C_RED. ============================================================ &_C_RESET.;
col o_enabled   clear;
col o_disabled  clear;
col value       clear;
