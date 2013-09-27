prompt &_C_REVERSE*** Show last created sql profiles.&_C_RESET
prompt * Usage: @profiles/last [days]
prompt * default 1 day

@inc/input_vars_init;
col prof_name  format a30;
col prof_descr format a30;
col category   format a10;
col type       format a10;
col created    format a19;
col modified   format a19;
col sql_text_trunc format a50;

set term off;
col days noprint new_value days
select 
    case 
        when translate('&1','x0123456789.','x') is null 
           then nvl('&1','2') 
        else '1'
    end days 
from dual;
set term on;

select
    p.name                 prof_name
   ,p.description prof_descr
   ,to_char(p.created       ,'yyyy-mm-dd hh24:mi:ss') as created
   ,to_char(p.last_modified ,'yyyy-mm-dd hh24:mi:ss') as modified
   ,p.category
   ,p.type
   ,p.FORCE_MATCHING
   ,substr(p.sql_text,1,50) sql_text_trunc
from 
    dba_sql_profiles p
where 
   greatest(p.created,p.last_modified)+0 > sysdate-&days
order by greatest(p.created,p.last_modified) desc
/
col prof_name  clear;
col prof_descr clear;
col category   clear;
col type       clear;
col created    clear;
col modified   clear;
undef days;
@inc/input_vars_undef;