@inc/input_vars_init.sql;

col exec new_val _exec noprint;

select
   &_IF_LOWER_THAN_ORA11 'asqlmon10.sql' exec
   &_IF_ORA11_OR_HIGHER  'asqlmon11.sql' exec
from dual;

@@&_exec &1 &2 &3 &4 &5 &6 &7 &8 &9 &10 &11 &12 &13 &14 &15 &16 &17 &18 &19 &20

undef _exec;
@inc/input_vars_undef.sql;