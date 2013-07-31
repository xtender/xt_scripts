@inc/input_vars_init;
col type  format    a20;
col owner format    a20;
col name  format    a30;
col text  format    a100;

select s.type,s.owner,s.name,s.line,s.text
from dba_source s
where upper(s.owner) like nvl(upper('&2'),'%')
  and s.name like upper('%&1%');

col type  clear;
col owner clear;
col name  clear;
col text  clear;
@inc/input_vars_undef;