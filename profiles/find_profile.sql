prompt &_C_REVERSE*** Find sql profiles by mask.&_C_RESET
prompt * Usage: @profiles/find_profile mask

@inc/input_vars_init;
col name           format a30;
col description    format a80;
col category       format a10;
col type           format a10;
col created        format a19;
col modified       format a19;
col sql_text_trunc format a50 trunc;

select
    p.name                                            as name
   ,p.description                                     as description
   ,to_char(p.created       ,'yyyy-mm-dd hh24:mi:ss') as created
   ,to_char(p.last_modified ,'yyyy-mm-dd hh24:mi:ss') as modified
   ,p.category                                        as category
   ,p.type                                            as type
   ,p.FORCE_MATCHING                                  as FORCE_MATCHING
   ,substr(p.sql_text,1,50)                           as sql_text_trunc
from 
    dba_sql_profiles p
where 
      upper(sql_text)    like upper('%&1%')
   or upper(name)        like upper('%&1%')
   or upper(description) like upper('%&1%')
order by greatest(p.created,p.last_modified) desc
/
col name        clear;
col description clear;
col category    clear;
col type        clear;
col created     clear;
col modified    clear;
@inc/input_vars_undef;
