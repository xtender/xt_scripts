prompt List of restore points:
col name for a30;
col time for a24;
col storage_size for 999g999 head "Storage size(MB)";
select 
   name
  ,to_char(time,'yyyy-mm-dd hh24:mi:ssxff3') as time
  ,storage_size/1024/1024 as storage_size
from v$restore_point;
