@inc/input_vars_init.sql

col table_owner     format a12
col table_name      format a30
col index_name      format a30
col partition_name  format a20
col column_name     format a30
col "#"             format 99
break on table_owner skip 3 on table_name on index_name on partition_name on created on last_ddl_time on mBytes on blocks skip 1 
select 
         ic.table_owner
        ,ic.table_name
--        ,ic.index_owner
        ,ic.index_name
        ,o.created
        ,o.last_ddl_time
        ,s.partition_name
        ,round(s.bytes/1024/1024,1) mBytes
        ,s.blocks
        ,ic.column_position "#"
        ,decode(ic.column_position,1,'','  ,')||ic.column_name column_name
from dba_ind_columns ic 
    ,dba_objects o
    ,dba_segments s
where
     ic.table_owner like nvl(upper('&2'),'%')
 and ic.table_name like upper('&1')
 and ic.index_owner     = o.owner
 and ic.index_name      = o.object_name
 and s.owner            = ic.index_owner
 and s.segment_name     = ic.index_name
 and s.segment_type     = o.object_type
 and s.PARTITION_NAME   = o.SUBOBJECT_NAME
order by
         1,2,3,4,5,6
         --,9
/
clear break 
col "#" clear 
@inc/input_vars_undef.sql