select
               sn.snap_id
              ,to_char(sn.begin_interval_time,'YYYY-MM-DD hh24:mi') as beg_interval
              ,sn.instance_number                                   as inst_id
              ,o.object_type                                        as type
              ,o.object_name                                        as name
              ,st.logical_reads_delta                               as logical_reads
              ,st.buffer_busy_waits_delta                           as bbw
              ,st.db_block_changes_delta                            as db_block_changes
              ,st.physical_reads_delta                              as phy_reads
              ,st.physical_writes_delta                             as phy_writes
              ,st.physical_reads_direct_delta                       as phy_reads_direct
              ,st.physical_writes_direct_delta                      as phy_writes_direct
              ,st.itl_waits_delta                                   as itl_waits
              ,st.row_lock_waits_delta                              as row_locks
              ,st.gc_cr_blocks_served_delta                         as gc_cr_blk_served
              ,st.gc_cu_blocks_served_delta                         as gc_cu_blk_served
              ,st.gc_buffer_busy_delta                              as gc_bbw
              ,st.gc_cr_blocks_received_delta                       as gc_cr_blk_received
              ,st.gc_cu_blocks_received_delta                       as gc_cu_blk_received
              ,st.space_used_delta                                  as space_used_delta
              ,st.space_allocated_delta                             as space_allocated_delta
              ,st.table_scans_delta                                 as table_scans
&_IF_ORA112_OR_HIGHER  ,st.CHAIN_ROW_EXCESS_DELTA
&_IF_ORA112_OR_HIGHER  ,st.PHYSICAL_READ_REQUESTS_DELTA
&_IF_ORA112_OR_HIGHER  ,st.PHYSICAL_WRITE_REQUESTS_DELTA
&_IF_ORA112_OR_HIGHER  ,st.OPTIMIZED_PHYSICAL_READS_DELTA
from   v$database            db
      ,dba_hist_seg_stat_obj o
      ,dba_hist_snapshot     sn
      ,dba_hist_seg_stat     st
where 
      db.dbid            = st.dbid
  and db.dbid            = sn.dbid
  and db.dbid            = o.dbid
  and st.snap_id         = sn.snap_id
  and st.instance_number = sn.instance_number
  and st.dbid            = o.dbid
  and st.ts#             = o.ts#
  and st.obj#            = o.obj#
  and st.dataobj#        = o.dataobj#
  and o.owner            like nvl(upper(&2),'%')
  and o.object_name      like upper(&1)
  and sn.end_interval_time > date'2014-01-01'
order by sn.snap_id,sn.begin_interval_time,sn.instance_number
/