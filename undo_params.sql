col tsname for a10;
col file_name for a40;
select 
   ts.tablespace_name as tsname
  ,ts.status
  ,ts.retention
  ,df.file_name
  ,df.bytes/1024/1024    as "MBytes"
  ,df.autoextensible
  ,df.maxbytes/1024/1024 as "Max MBytes"
from dba_tablespaces ts 
    ,dba_data_files df
where contents='UNDO'
and df.tablespace_name=ts.tablespace_name;
@param undo%
