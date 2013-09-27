@inc/input_vars_init;
col p_format new_value _format
select
    case
        when '&1' is not null
            then 'typical &1 &2 &3 &4 &5 &6 &7 &8 &9'
        else --'all -projection -outline'
            'typical'
    end p_format
from dual;
select * from table(dbms_xplan.display(null,null,'&_format'));
@inc/input_vars_undef;