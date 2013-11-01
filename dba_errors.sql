accept _owner prompt "Enter owner mask[%]: ";
accept _oname prompt "Enter name  mask[%]: ";
col OWNER       format a30;
col NAME        format a30;
col TYPE        format a20;
col text        format a80;
select 
     OWNER
    ,NAME
    ,TYPE
    ,SEQUENCE
    ,LINE
    ,POSITION
    ,TEXT
from dba_errors e 
where e.owner like nvl(upper('&_owner'),'%')
  and e.name  like nvl(upper('&_oname'),'%')
/
undef _owner _oname;
col OWNER       clear;
col NAME        clear;
col TYPE        clear;
col text        clear;