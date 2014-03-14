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
                ix.*
              ,(select sum(bytes) from dba_segments s where s.owner=ix.owner and s.segment_name=ix.index_name) seg_size 
              ,o.last_ddl_time
              ,o.created
        FROM    
                dba_indexes ix
               ,dba_objects o
        WHERE  1=1
        --
        and ix.table_owner like nvl(upper('&2'),'%')
        and ix.table_name  like upper('&1')
        and o.owner        = ix.owner 
        and o.object_name  = ix.index_name
        and o.SUBOBJECT_NAME is null
)
select--+ leading(i ic o) use_nl(i ic o)
         i.owner
        ,i.table_name
        ,i.index_name
        ,decode(i.VISIBILITY,'INVISIBLE'  ,'N','Y') as VISIBLE
        ,decode(i.UNIQUENESS,'NONUNIQUE','N','Y')  as UNIQ
        ,i.BLEVEL
        ,i.NUM_ROWS
        ,round(i.seg_size/1024/1024,1) seg_size
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
         owner,table_name,seg_size desc, DISTINCT_KEYS, index_name,"#"
/
clear break 
col "#" clear 
@inc/input_vars_undef.sql
