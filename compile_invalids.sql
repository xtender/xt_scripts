col object_type format a20;
accept _owner prompt "Enter owner mask[%]: ";
accept _otype prompt "Enter type  mask[%]: ";
accept _oname prompt "Enter name  mask[%]: ";

set echo on feed on serverout on


declare
    procedure p_exec(cmd varchar2) is
    begin
        execute immediate cmd;
        dbms_output.put_line('Success: '||cmd);
    exception when others then
        dbms_output.put_line('Error: '||cmd||': '||translate(sqlerrm,chr(10),' '));
    end;
begin
   for r in (
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
          and o.status='INVALID'
    )
    loop
        p_exec('alter '||r.object_type||' "'||r.owner||'"."'||r.object_name||'" compile');
    end loop;
end;
/
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
col object_type clear;
undef _owner _otype _oname;

set echo off feed off serverout off
