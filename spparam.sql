col family          for a6;
col sid             for a5;
col name            for a40;
col value           for a40;
col display_value   for a30;
col update_comment  for a15;

select *
from v$spparameter p
where lower(p.name) like lower('%&1%');
col family          clear;
col sid             clear;
col name            clear;
col value           clear;
col display_value   clear;
col update_comment  clear;