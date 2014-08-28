prompt *** DBA_FEATURE_USAGE_STATISTICS ***;
prompt;
accept _unused prompt "Print unused features?[Y/n, default=N]: " default "N";

break on usage skip page;
col usage format a15;
col name  format a90;

select 
   case when s.currently_used='FALSE' then 'NOT IN USE' 
        when s.currently_used='TRUE' then 'IN USE'
        else 'Currently USED: '||s.currently_used
   end usage
  ,s.name,s.detected_usages,s.first_usage_date,s.last_usage_date
from v$instance i, v$database d, dba_feature_usage_statistics s
where s.version        = i.version
  and s.dbid           = d.dbid
  and (upper('&_unused')='Y' or nvl(s.currently_used,'UNKNOWN') != 'FALSE')
order by decode(currently_used,'TRUE',1,'FALSE',2,3);

clear break;
col usage clear;
col name  clear;
undef _unused;
