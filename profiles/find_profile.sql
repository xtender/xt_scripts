prompt &_C_REVERSE*** Find sql profiles by mask.&_C_RESET
prompt * Usage: @profiles/find_profile mask

@inc/input_vars_init;
col prof_name  format a30;
col prof_descr format a30;
col category   format a10;
col type       format a10;
col created    format a19;
col modified   format a19;
col sql_text_trunc format a50;

select
    p.name                  as prof_name
   ,p.description           as prof_descr
   ,to_char(p.created       ,'yyyy-mm-dd hh24:mi:ss') as created
   ,to_char(p.last_modified ,'yyyy-mm-dd hh24:mi:ss') as modified
   ,p.category
   ,p.type
   ,p.FORCE_MATCHING
   ,substr(p.sql_text,1,50) sql_text_trunc
from 
    dba_sql_profiles p
where 
      upper(sql_text)    like upper('%&1%')
   or upper(name)        like upper('%&1%')
   or upper(description) like upper('%&1%')
order by greatest(p.created,p.last_modified) desc
/
col prof_name  clear;
col prof_descr clear;
col category   clear;
col type       clear;
col created    clear;
col modified   clear;
@inc/input_vars_undef;