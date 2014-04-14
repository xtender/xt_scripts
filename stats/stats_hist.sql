col object_type format a20;
col SAVTIME format a34;
col spare4 format a30;
col spare5 format a30;

select h.OBJ#
      ,o.owner
      ,o.object_name
      ,o.object_type
      ,h.SAVTIME
      ,h.FLAGS
      ,h.ROWCNT
      ,h.BLKCNT
      ,h.AVGRLN
      ,h.SAMPLESIZE
      ,h.ANALYZETIME
      ,h.CACHEDBLK
      ,h.CACHEHIT
      ,h.LOGICALREAD
      ,h.SPARE1
      ,h.SPARE2
      ,h.SPARE3
      ,h.SPARE4
      ,h.SPARE5
      ,h.SPARE6
from 
    dba_objects o
   ,sys.WRI$_OPTSTAT_TAB_HISTORY h
where
    o.object_id = h.obj#
and o.owner like nvl(upper('&2'),'%')
and o.object_name like upper('&1')
/
col spare4 clear;
col spare5 clear;
