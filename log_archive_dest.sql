col name   for a20;
col path   for a120;
col status for a7;

with dests as (
  select d.name
        ,s.value status
        ,d.value path
  from v$parameter d
      ,v$parameter s
  where d.name like 'log_archive_dest_%' escape '\'
  and s.name like 'log_archive_dest_state_%' escape '\'
  and s.name='log_archive_dest_state_'||substr(d.name,18)
)
select *
from dests
where path is not null;

col name clear;
col path clear;
col status clear;
