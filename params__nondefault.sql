col parameter       format a40;
col value           format a80;
col type            format a12;
col description     format a60;
col update_comment  format a30;

select  name as parameter
       ,decode
         (p.type
         ,1,'boolean'
         ,2,'string'
         ,3,'number'
         ,4,'file'
         ,6,'size(bytes)'
         ,'Unknown: '||p.type) type
       ,description
       ,decode(p.type,6,p.display_value,p.value) as value
       ,update_comment
       ,ISMODIFIED
       ,ISADJUSTED
       ,ISDEPRECATED
&_IF_ORA11_OR_HIGHER       ,ISBASIC
       ,ISSES_MODIFIABLE
       ,ISSYS_MODIFIABLE
       ,ISINSTANCE_MODIFIABLE
from v$parameter p 
where p.isdefault='FALSE'
and p.name not like 'log_archive_dest%'
and p.name like '\_%' escape '\'
/
col parameter       clear;
col value           clear;
col type            clear;
col description     clear;
col update_comment  clear;