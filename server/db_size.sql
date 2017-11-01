select 
       nvl(ts.name,'TOTAL SIZE') TS
      ,sum(bytes)/1024/1024 "FILESIZE(MB)"
from v$tablespace ts,v$datafile d
where ts.ts#=d.ts#
group by rollup(ts.name)
order by ts.name nulls last;