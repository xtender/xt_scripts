@inc/input_vars_init.sql
col owner           format a12
col table_owner     format a12
col table_name      format a20
col index_name      format a30
col partition_name  format a20
col column_name     format a30
col "#"             format 99
col BLEVEL          format 999
col VISIBLE         format a3
col UNIQ            format a4
col SEG_SIZE        heading "Blocks/Size(Mb)" format a28
col PARTITIONED     format a4 heading "Part"
col DISTINCT_KEYS   format 999g999g999g999
col "created/last ddl" format a21;

prompt &_C_REVERSE. *** Indexes: table_name like '&1' and owner like nvl(upper('&2'),'%') &_C_RESET
prompt &_C_RED. *** Size(MB) is valid only for 8kb blocksize. It is just multiplication of blocks*8kb &_C_RESET
break  on owner skip 3 on table_name on index_name on VISIBLE on UNIQ on BLEVEL on NUM_ROWS on SEG_BLOCKS on SEG_SIZE -
       on LEAF_BLOCKS on DISTINCT_KEYS on CL_FACTOR on LAST_ANALYZED on PARTITIONED on "created/last ddl" skip 1;
----------------------------------------
with sys_dba_segs(
       owner, segment_name, partition_name, segment_type, segment_type_id, segment_subtype, tablespace_id
       , tablespace_name, blocksize, header_file, header_block, bytes, blocks
       , extents, initial_extent, next_extent, min_extents, max_extents, max_size
       , retention, minretention, pct_increase, freelists, freelist_groups
       , relative_fno, buffer_pool_id, flash_cache, cell_flash_cache, segment_flags, segment_objd
       )
as (
select-- use_nl(so) push_pred(so)
       u.name, o.name, o.subname,
       so.object_type, s.type#,
       decode(bitand(s.spare1, 2097408), 2097152, 'SECUREFILE', 256, 'ASSM', 'MSSM'),
       ts.ts#, ts.name, ts.blocksize,
       f.file#, s.block#,
       s.blocks * ts.blocksize, s.blocks, s.extents,
       s.iniexts * ts.blocksize,
       s.extsize * ts.blocksize,
       s.minexts, s.maxexts,
       decode(bitand(s.spare1, 4194304), 4194304, bitmapranges, NULL),
       to_char(decode(bitand(s.spare1, 2097152), 2097152,
              decode(s.lists, 0, 'NONE', 1, 'AUTO', 2, 'MIN', 3, 'MAX',
                     4, 'DEFAULT', 'INVALID'), NULL)),
       decode(bitand(s.spare1, 2097152), 2097152, s.groups, NULL),
       decode(bitand(ts.flags, 3), 1, to_number(NULL),
                                      s.extpct),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.lists, 0, 1, s.lists)),
       decode(bitand(ts.flags, 32), 32, to_number(NULL),
              decode(s.groups, 0, 1, s.groups)),
       s.file#, bitand(s.cachehint, 3), bitand(s.cachehint, 12)/4,
       bitand(s.cachehint, 48)/16, NVL(s.spare1,0), o.dataobj#
from sys.user$ u, sys.obj$ o, sys.ts$ ts, sys.sys_objects so, sys.seg$ s,
     sys.file$ f
where s.file# = so.header_file
  and s.block# = so.header_block
  and s.ts# = so.ts_number
  and s.ts# = ts.ts#
  and o.obj# = so.object_id
  and o.owner# = u.user# (+)
  and s.type# = so.segment_type_id
  and o.type# = so.object_type_id
  and s.ts# = f.ts#
  and s.file# = f.relfile#
)
select
         i.owner
        ,i.table_name
        ,i.index_name
        ,decode(i.visibility,'VISIBLE','YES','NO') as VISIBLE
        ,decode(i.uniqueness,'UNIQUE','YES','NO')  as UNIQ
        ,i.BLEVEL
        ,i.NUM_ROWS
        ,(select to_char(sum(blocks),'FM999g999g999g999')||' / '|| (sum(bytes)/1024/1024)||' Mb'  from dba_segments s where s.owner=i.owner and s.segment_name=i.index_name)  as seg_size
        ,i.LEAF_BLOCKS
        ,i.DISTINCT_KEYS
        ,i.CLUSTERING_FACTOR as CL_FACTOR
        ,i.LAST_ANALYZED
        ,i.PARTITIONED
        ,(select to_char(o.created,'yyyy-mm-dd')
                 ||'/'||
                 to_char(o.last_ddl_time,'yyyy-mm-dd') 
          from dba_objects o 
          where i.index_name=o.object_name 
            and i.owner=o.owner 
            and o.object_type = 'INDEX'
         ) "created/last ddl"
        ,ic.column_position "#"
        ,decode(ic.column_position,1,'','  ,')||ic.column_name column_name
from dba_indexes i
    ,dba_ind_columns ic 
where
     ic.index_owner = i.owner
 and ic.index_name  = i.index_name
 and i.table_name  like upper('&1')
 and i.table_owner like nvl(upper('&2'),'%')
order by
         owner,table_name,index_name,"#"
/
clear break 
col owner           clear
col table_owner     clear
col table_name      clear
col index_name      clear
col partition_name  clear
col column_name     clear
col "#"             clear
col BLEVEL          clear
col VISIBLE         clear
col UNIQ            clear
col SEG_SIZE        clear
col PARTITIONED     clear
col DISTINCT_KEYS   clear
col "created/last ddl" clear;
@inc/input_vars_undef.sql
