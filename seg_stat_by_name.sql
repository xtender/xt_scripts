set timing off
col dbid new_val dbid noprint
select d.dbid from v$database d
/
select 
    to_char(sn.begin_interval_time,'yyyy-mm-dd hh24:"00"') beg_time
   ,to_char(sn.end_interval_time,'yyyy-mm-dd hh24:"00"')   end_time
   ,ss.snap_id
   ,LOGICAL_READS_DELTA
   ,BUFFER_BUSY_WAITS_DELTA
   ,DB_BLOCK_CHANGES_DELTA
   ,PHYSICAL_READS_DELTA
   ,PHYSICAL_WRITES_DELTA
   ,PHYSICAL_READS_DIRECT_DELTA
   ,PHYSICAL_WRITES_DIRECT_DELTA
   ,ITL_WAITS_DELTA
   ,ROW_LOCK_WAITS_DELTA
   --,GC_CR_BLOCKS_SERVED_DELTA
   --,GC_CU_BLOCKS_SERVED_DELTA
   --,GC_BUFFER_BUSY_DELTA
   --,GC_CR_BLOCKS_RECEIVED_DELTA
   --,GC_CU_BLOCKS_RECEIVED_DELTA
   ,SPACE_USED_DELTA
   ,SPACE_ALLOCATED_DELTA
   ,TABLE_SCANS_DELTA
from dba_segments s
     join dba_objects o
          on  s.owner        = o.owner
          and s.segment_name = o.OBJECT_NAME
          and o.OBJECT_TYPE in ('TABLE','INDEX')
     join dba_hist_seg_stat ss
          on  ss.dbid    = &dbid -- (select d.dbid from v$database d) -- 473009168
          and ss.obj#       = o.OBJECT_ID
          and ss.dataobj#   = o.DATA_OBJECT_ID
          and ss.ts#        = 5
          and ss.instance_number = 1
     join dba_hist_snapshot sn
          on  ss.snap_id    = sn.snap_id
          and sn.dbid       = &dbid
          and sn.instance_number = sys_context('USERENV','INSTANCE')
where 
      s.owner        		like nvl('&owner','%')
  and s.segment_name 		like nvl('&name','%')
  and s.segment_type 		in ('TABLE','INDEX')
order by ss.snap_id desc
/
