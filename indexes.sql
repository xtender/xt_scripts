@inc/input_vars_init.sql
col owner           format a12
col table_owner     format a12
col table_name      format a30
col index_name      format a30
col partition_name  format a20
col column_name     format a30
col "#"             format 99
col BLEVEL          format 999
col VISIBLE         format a3
col UNIQ            format a4
col SEG_BLOCKS      heading "Sum blocks"
col SEG_SIZE        heading "Size(Mb)"
col PARTITIONED     format a4 heading "Part"
prompt &_C_REVERSE. *** Indexes: table_name like '&1' and owner like nvl(upper('&2'),'%') &_C_RESET
prompt &_C_RED. *** Size(MB) is valid only for 8kb blocksize. It is just multiplication of blocks*8kb &_C_RESET
break  on owner skip 3 on table_name on index_name on VISIBLE on UNIQ on BLEVEL on NUM_ROWS on SEG_BLOCKS on SEG_SIZE -
       on LEAF_BLOCKS on DISTINCT_KEYS on CL_FACTOR on LAST_ANALYZED on PARTITIONED on created on last_ddl_time skip 1;

with i as (
        SELECT
                IND_OBJECT.NAME                                      as INDEX_NAME
               ,IND_OWNER.NAME                                       as OWNER
               ,TAB_OWNER.NAME                                       as TABLE_OWNER
               ,TAB_OBJECT.NAME                                      as TABLE_NAME
               ,DECODE(BITAND(IND$.PROPERTY, 1)
                      ,0 ,'No'
                      ,1 ,'Yes'
                      ,'Err')                                        as UNIQ
               ,IND$.BLEVEL                                          as BLEVEL
               ,IND$.LEAFCNT                                         as LEAF_BLOCKS
               ,IND$.DISTKEY                                         as DISTINCT_KEYS
               ,IND$.CLUFAC                                          as CLUSTERING_FACTOR
               ,IND$.ROWCNT                                          as NUM_ROWS
               ,IND$.ANALYZETIME                                     as LAST_ANALYZED
               ,DECODE(BITAND(IND$."PROPERTY", 2), 2, 'YES', 'NO')   as PARTITIONED
               ,DECODE(BITAND(IND$."FLAGS", 2097152)
                      ,2097152
                      ,'NO'
                      ,'Yes')                                        as VISIBLE
               , IND_OBJECT.CTIME                                    as CREATED
               , IND_OBJECT.MTIME                                    as LAST_DDL_TIME
               ,IND_SEG.BLOCKSIZE                                    as blocksize
               ,IND_SEG.blocks                                       as seg_blocks
        FROM    
                SYS.IND$          IND$
               ,SYS.USER$         TAB_OWNER
               ,SYS.OBJ$          TAB_OBJECT
               ,SYS.USER$         IND_OWNER
               ,SYS.OBJ$          IND_OBJECT
               ,(SELECT 
                    op.name
                   ,op.owner#
                   ,min(stsI.BLOCKSIZE)  BLOCKSIZE
                   ,sum(segI.BLOCKS)     blocks
                 FROM SYS.obj$     op
                    ,(select 1  TYPE#, OBJ#, FILE#, BLOCK#, TS# from SYS.IND$
                      union all
                      select 20 TYPE#, OBJ#, FILE#, BLOCK#, TS# from SYS.INDPART$
                      union all
                      select 34 TYPE#, OBJ#, FILE#, BLOCK#, TS# from SYS.INDSUBPART$
                     ) VI
                    ,SYS.SEG$        segI
                    ,SYS.TS$         stsI
                WHERE  
                      VI.OBJ#      = op.OBJ#
                  and VI.TYPE#     = op.TYPE#
                  and segI.FILE#   = VI.FILE# 
                  AND segI.BLOCK#  = VI.BLOCK# 
                  AND segI.TS#     = VI.TS# 
                  AND segI.TYPE#   = 6
                  AND segI.TS#     = stsI.TS#
                 group by op.name, op.owner#
                ) IND_SEG
        WHERE  
               IND_OWNER.USER#               = IND_OBJECT.OWNER#
           AND IND_OBJECT.OBJ#               = IND$.OBJ#
           AND IND$.BO#                      = TAB_OBJECT.OBJ#
           AND TAB_OBJECT.OWNER#             = TAB_OWNER.USER#
           AND IND_SEG.name                  = IND_OBJECT.name
           and IND_SEG.owner#                = IND_OBJECT.OWNER#
           AND BITAND(IND$.FLAGS, 4096)      = 0
           AND BITAND(IND_OBJECT.FLAGS, 128) = 0
        --
        and TAB_OWNER.NAME  like nvl(upper('&2'),'%')
        and TAB_OBJECT.NAME like upper('&1')
)
select--+ leading(i ic o) use_nl(i ic o)
         i.owner
        ,i.table_name
        ,i.index_name
        ,i.VISIBLE
        ,i.UNIQ
        ,i.BLEVEL
        ,i.NUM_ROWS
        ,i.seg_blocks
        ,round(i.seg_blocks*i.blocksize/1024/1024,1) seg_size
        ,i.LEAF_BLOCKS
        ,i.DISTINCT_KEYS
        ,i.CLUSTERING_FACTOR as CL_FACTOR
        ,i.LAST_ANALYZED
        ,i.PARTITIONED
        ,i.created
        ,i.last_ddl_time
        ,ic.column_position "#"
        ,decode(ic.column_position,1,'','  ,')||ic.column_name column_name
from i
    ,dba_ind_columns ic 
where
     ic.index_owner = i.owner
 and ic.index_name  = i.index_name
order by
         owner,table_name,index_name,"#"
/
clear break 
col "#" clear 
@inc/input_vars_undef.sql
