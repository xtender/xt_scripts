select owner, segment_name, partition_name, tablespace_name, extent_id
from dba_extents
where file_id = &file_id
and &block_id between block_id and block_id + blocks - 1;
