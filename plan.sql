@inc/input_vars_init.sql
prompt;
Prompt Childs:
select child_number from v$sql s where s.sql_id ='&1';

col p_child  new_value _child
col p_format new_value _format
select
    case 
        when '&2' is not null
            and translate('&2','x0123456789','x') is null
        then '&2'
        else null
    end p_child,
    case
        when '&2' is not null
            and translate('&2','x0123456789','x') is not null
        then 'typical &2 &3 &4 &5 &6 &7 &8 &9'
        when replace('&3 &4 &5 &6 &7 &8 &9',' ') is not null
        then 'typical &3 &4 &5 &6 &7 &8 &9'
        else --'all -projection -outline'
            'typical'
    end p_format
from dual;

col plan_table_output format a240
select * 
from table(dbms_xplan.display_cursor('&1','&_child','&_format'));
undef _child 
undef _format
@inc/input_vars_undef.sql