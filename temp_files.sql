set term off;
col len_file new_val len_file;
col len_ts   new_val len_ts;
select 
   'a'||max(length(FILE_NAME      )) len_file
  ,'a'||max(length(TABLESPACE_NAME)) len_ts
from dba_temp_files;

col FILE_NAME   for &len_file
col TS          for &len_ts
col SIZE        for a12 just right;
col USER_SIZE   for a12 just right;
col MAX_SIZE   for a12 just right;
set term on;

select
 FILE_NAME
,FILE_ID
,TABLESPACE_NAME TS
,lpad(
    case 
        when BYTES>1024*1024*1024 and mod(BYTES,1024*1024*1024)=0
            then to_char(BYTES/(1024*1024*1024))||' GB'
        when BYTES>1024*1024*1024 and mod(BYTES,1024*1024*1024)!=0
            then to_char(BYTES/(1024*1024*1024),'999999.9')||' GB'
        when BYTES>1024*1024 and mod(BYTES,1024*1024)=0
            then to_char(BYTES/(1024*1024),'99999999')||' MB'
        when BYTES>=0 
            then to_char(BYTES/(1024*1024),'99999999.9')||' MB'
        else ''
    end
    ,12,' ') "SIZE"
,BLOCKS
,STATUS
,RELATIVE_FNO
,AUTOEXTENSIBLE
,lpad(
    case 
        when MAXBYTES>1024*1024*1024 and mod(MAXBYTES,1024*1024*1024)=0
            then to_char(MAXBYTES/(1024*1024*1024))||' GB'
        when MAXBYTES>1024*1024*1024 and mod(MAXBYTES,1024*1024*1024)!=0
            then to_char(MAXBYTES/(1024*1024*1024),'999999.9')||' GB'
        when MAXBYTES>1024*1024 and mod(MAXBYTES,1024*1024)=0
            then to_char(MAXBYTES/(1024*1024),'99999999')||' MB'
        when MAXBYTES>=0 
            then to_char(MAXBYTES/(1024*1024),'99999999.9')||' MB'
        else ''
    end
    ,12,' ') "MAX_SIZE"
,MAXBLOCKS
,INCREMENT_BY
,USER_BYTES
,lpad(
    case 
        when USER_BYTES>1024*1024*1024 and mod(USER_BYTES,1024*1024*1024)=0
            then to_char(USER_BYTES/(1024*1024*1024))||' GB'
        when USER_BYTES>1024*1024*1024 and mod(USER_BYTES,1024*1024*1024)!=0
            then to_char(USER_BYTES/(1024*1024*1024),'999999.9')||' GB'
        when USER_BYTES>1024*1024 and mod(USER_BYTES,1024*1024)=0
            then to_char(USER_BYTES/(1024*1024),'99999999')||' MB'
        when USER_BYTES>=0 
            then to_char(USER_BYTES/(1024*1024),'99999999.9')||' MB'
        else ''
    end
    ,12,' ') "USER_SIZE"
,USER_BLOCKS
from dba_temp_files
/
col FILE_NAME clear;
col SIZE clear;
col USER_SIZE clear;