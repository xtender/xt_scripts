prompt *** Show params from v$ses_optimizer_env

accept _sid      prompt "SID[empty for current]: ";
accept _param    prompt "Parameter mask[%]: " default '%';
accept _defaults prompt "Show defaults?[N/y, def=N]: " default 'n';

col id           noprint;
col name         for a64;
col value        for a30;
col sql_feature  for a30;

select id,name,value,e.isdefault,sql_feature
from v$ses_optimizer_env e
where e.sid = to_number(nvl('&_sid',userenv('sid')))
  and e.name like lower('&_param')
  and e.isdefault = decode(lower('&_defaults'),'n','NO',e.isdefault)
order by name
/
undef _sid _param _defaults
col id           clear;
col name         clear;
col value        clear;
col sql_feature  clear;
