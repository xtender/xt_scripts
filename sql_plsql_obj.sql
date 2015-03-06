col owner           for a16;
col object_name     for a30;
col object_type     for a20;
col text            for a120;

select 
   a.inst_id
  ,a.SQL_ID
  ,o.owner,o.object_name,o.object_type
  ,s.line
  ,rtrim(s.text,chr(10)) text
from
    gv$sqlarea a
    left join dba_objects o
              on a.PROGRAM_ID = o.OBJECT_ID
    left join dba_source s
              on o.owner=s.owner
              and o.OBJECT_NAME=s.name
              and s.line between a.PROGRAM_LINE#-5 and a.PROGRAM_LINE#+5
where a.SQL_ID='&1'
order by 1,2,3,4,5,6
/
col owner           clear;
col object_name     clear;
col object_type     clear;
col text            clear;
