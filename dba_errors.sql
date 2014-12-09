accept _owner prompt "Enter owner mask[%]  : ";
accept _oname prompt "Enter name  mask[%]  : ";
accept _attr  prompt "Show warnings(Y/N)[N]: " default "N"

col OWNER       format a30;
col NAME        format a30;
col TYPE        format a20;
col attribute   format a7;
col text        format a80;
select 
     OWNER
    ,NAME
    ,TYPE
    ,SEQUENCE
    ,attribute
    ,LINE
    ,POSITION
    ,TEXT
from dba_errors e 
where e.owner like nvl(upper('&_owner'),'%')
  and e.name  like nvl(upper('&_oname'),'%')
  and (upper('&_attr')='Y' or attribute='ERROR')
/
undef _owner _oname _attr;
col OWNER       clear;
col NAME        clear;
col TYPE        clear;
col attribute   clear;
col text        clear;