accept _ts prompt 'Tablespace mask[%]: ' default %;
col tablespace_name for a30;
col file_name       for a80;
col mbytes          for a15;
col max_mbytes      for a15;
col user_mbytes     for a15;
col status          for a10;
col FILE_ID         for 9999;
col REL_FNO         for 9999;
with f as (
      select 
          df.file_name
         ,df.file_id
         ,df.tablespace_name
         ,df.bytes
         ,df.blocks
         ,df.status
         ,df.relative_fno
         ,df.autoextensible
         ,df.maxbytes
         ,df.maxblocks
         ,df.increment_by
         ,df.user_bytes
         ,df.user_blocks
      from dba_data_files df 
      where tablespace_name like upper('&_ts')
      union all
      select
          tf.file_name
         ,tf.file_id
         ,tf.tablespace_name
         ,tf.bytes
         ,tf.blocks
         ,tf.status
         ,tf.relative_fno
         ,tf.autoextensible
         ,tf.maxbytes
         ,tf.maxblocks
         ,tf.increment_by
         ,tf.user_bytes
         ,tf.user_blocks
      from dba_temp_files tf 
      where tablespace_name like upper('&_ts')
)
select
    f.tablespace_name
   ,f.file_id
   ,f.relative_fno as rel_fno
   ,to_char(round(f.bytes     /1024/1024,2),'999g999g999d00') as mbytes
   ,to_char(round(f.maxbytes  /1024/1024,2),'999g999g999d00') as max_mbytes
   ,f.autoextensible
   ,f.blocks
   ,f.status
   ,f.maxblocks
   ,f.increment_by
   ,to_char(round(f.user_bytes/1024/1024,2),'999g999g999d00') as user_mbytes
   ,f.user_blocks
   ,f.file_name
from f
order by f.tablespace_name,f.file_id
/
undef _ts
col tablespace_name clear;
col file_name       clear;
col mbytes          clear;
col max_mbytes      clear;
col user_mbytes     clear;
col status          clear;
col FILE_ID         clear;
col REL_FNO         clear;
