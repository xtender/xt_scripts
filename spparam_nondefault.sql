@inc/input_vars_init;
col family          for a6;
col sid             for a5;
col name            for a40;
col type            for a12;
col value           for a40;
col display_value   for a40;
col isspecified     for a5;
col ordinal         for 99 heading "##"
col update_comment  for a15;

select *
from v$spparameter p
where ISSPECIFIED = 'TRUE' and 
  (
     lower(p.name) like lower('%&1%')
  or ('&2' is not null and lower(p.name) like lower('%&2%'))
  or ('&3' is not null and lower(p.name) like lower('%&3%'))
  or ('&4' is not null and lower(p.name) like lower('%&4%'))
  or ('&5' is not null and lower(p.name) like lower('%&5%'))
  or ('&6' is not null and lower(p.name) like lower('%&6%'))
  or ('&7' is not null and lower(p.name) like lower('%&7%'))
  )
/
col family          clear;
col sid             clear;
col name            clear;
col type            clear;
col value           clear;
col display_value   clear;
col isspecified     clear;
col ordinal         clear;
col update_comment  clear;
@inc/input_vars_undef;