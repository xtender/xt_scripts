col filename for a80;
select ts.name,d.NAME as filename,bytes/1024/1024 "FILESIZE(MB)"
from v$tablespace ts,v$datafile d
where ts.ts#=d.ts#
order by ts.name,d.name;