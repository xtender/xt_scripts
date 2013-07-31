col owner           for a10
col object_name     for a30
col text            for a120

select 
   a.inst_id
  ,a.SQL_ID
  ,p.owner,p.object_name
  ,s.line
  ,rtrim(s.text,chr(10)) text
from
    gv$sqlarea a
    left join dba_procedures p
              on a.PROGRAM_ID=p.OBJECT_ID
    left join dba_source s
              on p.owner=s.owner
              and p.OBJECT_NAME=s.name
              and s.line between a.PROGRAM_LINE#-5 and a.PROGRAM_LINE#+5
where a.SQL_ID='&1'
order by 1,2,3,4,5
/
col owner           clear
col object_name     clear
col text            clear
