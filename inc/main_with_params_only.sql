set head off;
col ifhelp new_val _ifhelp noprint
select 
   case
      when lower('&1')='--help' or '&1.&2.&3.&4' is null
        then 'inc/comment_on' 
        else 'inc/null' 
      end ifhelp 
from dual;
col ifhelp clear;
set head on;
@&_ifhelp