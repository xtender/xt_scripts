col name  format a30;
col value format a20;
select num
      ,name
      ,ordinal
      ,value
      ,isdefault
from v$parameter_valid_values 
where name like '%&1%' escape '\'
/
col name  clear;
col value clear;