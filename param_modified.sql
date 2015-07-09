@inc/input_vars_init;
col name            format a40;
col value           format a25;
col display_value   format a20;
col deflt           format a12;
col type            format a12;
col description     format a60 WORD_WRAPPED;
col update_comment  format a20;
col modifiable      format a10;
col ISMODIFIED      format a5;
col ISADJUSTED      format a5;
col ISDEPRECATED    format a5;
select 
                         p.name
&_IF_LOWER_THAN_ORA10   ,p.value
&_IF_ORA10_OR_HIGHER    ,case when p.type=6 or lnnvl(p.display_value<>p.value)
&_IF_ORA10_OR_HIGHER               then nvl(p.display_value,p.value)
&_IF_ORA10_OR_HIGHER          else p.display_value||' ('||p.value||')' 
&_IF_ORA10_OR_HIGHER     end                                                                             as value
                        ,p.isdefault                                                                     as deflt
                        ,decode(p.type,1,'boolean',2,'string',3,'number',4,'file',6,'size(B)',p.type)as type
                        ,p.description                                                                   as description
                        ,p.update_comment                                                                as update_comment
                        ,ltrim(''
&_IF_ORA10_OR_HIGHER              ||decode(p.ISINSTANCE_MODIFIABLE, 'TRUE', ',INST')
                                  ||decode(p.ISSYS_MODIFIABLE     , 'TRUE', ',SYS' )
                                  ||decode(p.ISSES_MODIFIABLE     , 'TRUE', ',SES' )
                                , ','
                              )                                                                     as MODIFIABLE
                        ,decode(p.ISMODIFIED,'MODIFIED','TRUE','FALSE')                             as ISMODIFIED
                        ,p.ISADJUSTED
&_IF_ORA10_OR_HIGHER    ,p.ISDEPRECATED
&_IF_ORA11_OR_HIGHER    ,p.ISBASIC
from
   v$parameter p
where
   p.ISMODIFIED='MODIFIED'
order by name
/
col name            clear;
col value           clear;
col display_value   clear;
col deflt           clear;
col type            clear;
col description     clear;
col update_comment  clear;
col modifiable      clear;
col ISMODIFIED      clear;
col ISADJUSTED      clear;
col ISDEPRECATED    clear;
@inc/input_vars_undef;