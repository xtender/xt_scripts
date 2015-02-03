col "Tablespace" for a20;
col "File name"  for a60;
col "MBytes"     for a18;
SELECT 
       ts.name "Tablespace"
      ,d.file# 
      ,d.name  "File name"
      ,to_char(d.bytes/1024/1024,'999g999g999g999d9') "MBytes"
      ,d.blocks
      ,d.BLOCK_SIZE
      ,i.asynch_io
      ,i.access_method
FROM   v$datafile d,
       v$iostat_file i,
       v$tablespace ts
WHERE  d.file# = i.file_no
and    d.ts#   = ts.TS#
AND    i.filetype_name  = 'Data File'
order by 1,2
/
col "Tablespace" clear;
col "File name" clear;
col "MBytes"    clear;
