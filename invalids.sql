col object_type format a20;
col object_name format a30;
accept _owner prompt "Enter owner mask[%]: ";
accept _otype prompt "Enter type  mask[%]: ";
accept _oname prompt "Enter name  mask[%]: ";
select 
     owner
    ,object_type
    ,object_name
    ,status 
    ,o.timestamp
from dba_objects o 
where o.owner     like nvl(upper('&_owner'),'%')
  and object_type like nvl(upper('&_otype'),'%')
  and object_name like nvl(upper('&_oname'),'%')
  and o.status='INVALID';
col object_name clear;
col object_type clear;
undef _owner _otype _oname;