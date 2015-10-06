col OWNER           for a30;
col SEGMENT_NAME    for a30;
col PARTITION_NAME  for a30;
col SEGMENT_TYPE    for a12;
col TABLESPACE_NAME for a20;

accept __FILE  prompt "FILE_ID: ";
accept __BLOCK prompt "BLOCK_ID: ";
select 
 e.OWNER
,e.SEGMENT_NAME
,e.PARTITION_NAME
,e.SEGMENT_TYPE
,e.TABLESPACE_NAME
,e.EXTENT_ID
,e.FILE_ID
,e.BLOCK_ID
,e.BYTES
,e.BLOCKS
,e.RELATIVE_FNO
from dba_extents e
where file_id = &__FILE
	and &__BLOCK between block_id and block_id + blocks - 1
	and rownum = 1
/

col OWNER           clear;
col SEGMENT_NAME    clear;
col PARTITION_NAME  clear;
col SEGMENT_TYPE    clear;
col TABLESPACE_NAME clear;
undef __BLOCK __FILE;