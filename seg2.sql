prompt ********************************************
prompt Show table/index/lob segments;
prompt Usage: @seg2 seg_name [owner];
prompt or:    @seg2 [owner.]seg_name;

@inc/input_vars_init;
col _SEG_OWNER  new_value _SEG_OWNER    noprint;
col _SEG_NAME   new_value _SEG_NAME     noprint;
set termout off timing off
select
  upper(decode(instr('&1','.')
          ,0,nvl('&2','%')
          ,substr('&1',1,instr('&1','.')-1)
        )) "_SEG_OWNER"
 ,upper(decode(instr('&1','.')
          ,0,'&1'
          ,substr('&1',instr('&1','.')+1)
        )) "_SEG_NAME"
from dual;

COL owner           FOR A15;
COL segment_name    FOR A30;
COL partition_name  FOR A30;
COL size_mb         FOR A15;
COL segment_type    FOR A15;
COL segment_subtype FOR A10;
set termout on;
---------------
with sys_dba_segs
(owner, segment_name, partition_name, segment_type, segment_type_id, segment_subtype, tablespace_id, tablespace_name, blocksize, header_file, header_block, bytes, blocks, extents, initial_extent, next_extent, min_extents, max_extents, max_size, retention, minretention, pct_increase, freelists, freelist_groups, relative_fno, buffer_pool_id, flash_cache, cell_flash_cache, segment_flags, segment_objd)
as 
(
   select
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
                           s.owner
                          ,s.segment_name
                          ,s.partition_name
                          ,to_char(s.bytes/1024/1024,'999g999g990d9',q'[nls_numeric_characters='. ']') size_mb
                          ,s.blocks
                          ,s.segment_type
    &_IF_ORA11_OR_HIGHER  ,s.segment_subtype
                          ,s.tablespace_name
from sys_dba_segs s
where 
     s.segment_name like '&_SEG_NAME'
 and s.owner        like '&_SEG_OWNER'
--  and segment_type_id = decode(upper('input_param'),'TABLE',5,'INDEX',6,'LOB',8)
order by 1,2,3
/
col _SEG_OWNER  clear;
col _SEG_NAME   clear;
undef _SEG_NAME _SEG_OWNER

COL owner           clear;
COL segment_name    clear;
COL partition_name  clear;
COL size_mb         clear;
COL segment_type    clear;
COL segment_subtype clear;

@inc/input_vars_undef;
