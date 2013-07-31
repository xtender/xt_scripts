select segment_name
from dba_extents
where file_id = &__FILE
	and &__BLOCK between block_id and block_id + blocks - 1
	and rownum = 1
/
