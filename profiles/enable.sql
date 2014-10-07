@inc/input_vars_init;
exec if '&1' is not null then DBMS_SQLTUNE.ALTER_SQL_PROFILE('&1','STATUS','ENABLED'); end if;

col prof_name  format a30;
col category   format a10;
col status     format a8; 
col modified   format a19;
col prof_descr format a30;
col type       format a10;
col created    format a19;

select 
    p.name          as prof_name
   ,p.category
   ,p.status
   ,to_char(p.last_modified ,'yyyy-mm-dd hh24:mi:ss') as modified
   ,p.description                                     as prof_descr
   ,p.type
   ,to_char(p.created       ,'yyyy-mm-dd hh24:mi:ss') as created
   ,p.force_matching
from dba_sql_profiles p
where p.name='&1';

col prof_name  clear;
col category   clear;
col status     clear;
col modified   clear;
col prof_descr clear;
col type       clear;
col created    clear;
@inc/input_vars_undef;