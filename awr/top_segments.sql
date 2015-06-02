col dbid new_val _dbid;
select distinct dbid, db_name
from dba_hist_database_instance i
order by (select count(*) from v$database db where db.dbid = i.dbid)
/
accept _dbid prompt "Enter dbid[&_dbid]: " default &_dbid;
accept beg_time prompt "Start time[yyyy-mm-dd hh24:mi:ss]: ";
accept end_time prompt "End   time[yyyy-mm-dd hh24:mi:ss]: ";

prompt * Available statistics for sorting:
prompt 1  LOGICAL_READS
prompt 2  DB_BLOCK_CHANGES
prompt 3  PHYSICAL_READS &_C_RED  [default] &_C_RESET;
prompt 4  PHYSICAL_WRITES
prompt 5  PHYSICAL_READS_DIRECT
prompt 6  PHYSICAL_WRITES_DIRECT
prompt 7  BUFFER_BUSY_WAITS
prompt 8  ITL_WAITS
prompt 9  TABLE_SCANS
prompt 10 CHAIN_ROW_EXCESS
prompt 11 PHYSICAL_READ_REQUESTS
prompt 12 PHYSICAL_WRITE_REQUESTS
accept _sort prompt "Choose statistic for sorting[3]: " default 3;

col owner           for a30;
col object_name     for a30;
col subobject_name  for a30;
col object_type     for a30;
col tablespace_name for a30;

with 
 snaps as (
          select dbid, snap_id, instance_number inst_id,begin_interval_time as beg_time
          from dba_hist_snapshot sn
          where sn.dbid=&_dbid
            and sn.end_interval_time   >= timestamp'&beg_time'
            and sn.begin_interval_time <= timestamp'&end_time'
 )
,seg_stats as (
            select
               ob.owner
              ,ob.object_name
              ,ob.subobject_name
              ,ob.object_type
              ,ob.tablespace_name
              ,sum(st.LOGICAL_READS_DELTA           ) LOGICAL_READS
              ,sum(st.DB_BLOCK_CHANGES_DELTA        ) DB_BLOCK_CHANGES
              ,sum(st.PHYSICAL_READS_DELTA          ) PHYSICAL_READS
              ,sum(st.PHYSICAL_WRITES_DELTA         ) PHYSICAL_WRITES
              ,sum(st.PHYSICAL_READS_DIRECT_DELTA   ) PHYSICAL_READS_DIRECT
              ,sum(st.PHYSICAL_WRITES_DIRECT_DELTA  ) PHYSICAL_WRITES_DIRECT
              ,sum(st.BUFFER_BUSY_WAITS_DELTA       ) BUFFER_BUSY_WAITS
              ,sum(st.ITL_WAITS_DELTA               ) ITL_WAITS
              ,sum(st.TABLE_SCANS_DELTA             ) TABLE_SCANS
              ,sum(st.CHAIN_ROW_EXCESS_DELTA        ) CHAIN_ROW_EXCESS
              ,sum(st.PHYSICAL_READ_REQUESTS_DELTA  ) PHYSICAL_READ_REQUESTS
              ,sum(st.PHYSICAL_WRITE_REQUESTS_DELTA ) PHYSICAL_WRITE_REQUESTS
            from snaps sn
                ,dba_hist_seg_stat st
                ,dba_hist_seg_stat_obj ob
            where sn.dbid     = st.dbid
              and sn.snap_id  = st.snap_id
              and sn.inst_id  = st.instance_number
              and st.dbid     = ob.dbid
              and st.ts#      = ob.ts#
              and st.obj#     = ob.obj#
              and st.dataobj# = ob.dataobj#
            group by 
               ob.owner
              ,ob.object_name
              ,ob.subobject_name
              ,ob.object_type
              ,ob.tablespace_name
 )
,sorts as (
            select *
            from (
                 select 
                    dense_rank()
                       over(order by decode(&_sort
                                             , 1 , LOGICAL_READS
                                             , 2 , DB_BLOCK_CHANGES
                                             , 3 , PHYSICAL_READS
                                             , 4 , PHYSICAL_WRITES
                                             , 5 , PHYSICAL_READS_DIRECT
                                             , 6 , PHYSICAL_WRITES_DIRECT
                                             , 7 , BUFFER_BUSY_WAITS
                                             , 8 , ITL_WAITS
                                             , 9 , TABLE_SCANS
                                             , 10, CHAIN_ROW_EXCESS
                                             , 11, PHYSICAL_READ_REQUESTS
                                             , 12, PHYSICAL_WRITE_REQUESTS
                                           ) desc
                    ) N
                   ,ss.*
                 from seg_stats ss
            )
            where N <=10
)
select * 
from sorts
/
col dbid            clear;
col owner           clear;
col object_name     clear;
col subobject_name  clear;
col object_type     clear;
col tablespace_name clear;
undef               _dbid;
undef               beg_time;
undef               end_time;
