@inc/input_vars_init;
prompt ;
prompt &_C_REVERSE *** Show values from v$sql_optimizer_env by sql_id &_C_RESET;
prompt * Usage: &_C_BOLD @opt_env_sql SQL_ID [mask] &_C_RESET;
prompt * By default it shows only nondefault values. Specify <mask> to filter all params by mask.
col name  for a40;
col value for a25;

break on sql_id on child_number skip 1;

select 
    e.sql_id
  , e.child_number
  , e.name
  , e.value
  , e.isdefault
from v$sql_optimizer_env e 
where e.sql_id='&1'
and ( 
        ('&2' is not null and regexp_like(e.name,q'[&2]','i'))
    or 
        ('&2' is     null and e.isdefault = 'NO')
    )
order by 1,2,3
/
col name  clear;
col value clear;
clear break;
@inc/input_vars_undef;