col name for a20;
col value for a10;
col destination for a120;
select
     d.name
    ,s.value
    ,d.value destination
from v$parameter d
    ,v$parameter s
where d.name like 'log_archive_dest_%' escape '\'
and s.name like 'log_archive_dest_state_%' escape '\'
and s.name='log_archive_dest_state_'||substr(d.name,18)
and s.value is not null
and d.value is not null;