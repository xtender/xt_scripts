col owner           format a20
col index_name      format a30
col uniq            format a6
col tablespace_name format a20;
col cols            format a40;
break on owner on index_name on uniqueness on blevel on leaf_blocks on distinct_keys on num_rows on last_analyzed on tablespace_name skip 1;
with 
ind1 as (
      select-- no_merge
            rownum rn
           ,i1.owner
           ,i1.index_name
           ,o.object_id
           
           ,i1.tablespace_name
           ,i1.uniqueness
           ,i1.blevel
           ,i1.leaf_blocks
           ,i1.distinct_keys
           ,i1.num_rows
           ,i1.last_analyzed
           ,decode(o.object_type
                  ,'INDEX'
                  ,xmlcast(dbms_xmlgen.getxmltype(q'[
                       SELECT
                              ltrim( max( sys_connect_by_path( nvl(attrcol$.name, col$.name), ',' )),',') as cols
                       FROM   
                                SYS.ICOL$    
                               ,SYS.COL$     
                               ,SYS.ATTRCOL$ 
                       where  
                              ICOL$."BO#"     = COL$."OBJ#"
                          and ICOL$."INTCOL#" = COL$."INTCOL#"
                          and col$.obj#       = attrcol$.obj#(+)
                          and col$.intcol#    = attrcol$.intcol#(+)
                          and icol$.obj#      = ]'|| nvl(to_char(o.object_id,'999999999999999'),'0') ||q'[
                       start with 
                          icol$.obj# = ]'|| nvl(to_char(o.object_id,'999999999999999'),'0') ||q'[
                          and pos#   = 1
                       connect by 
                          icol$.obj# = prior icol$.obj#
                          and pos#   = prior pos# + 1]'
                     )
                    as varchar2(100)
                 )
            ) cols
      from dba_indexes i1
          ,dba_objects o
          --,sys.ind$
      where  
            i1.owner       like nvl(upper('&2'),'%')
        and i1.table_owner  = i1.owner
        and i1.table_name   = upper('&1')
       
        and o.owner         = i1.owner
        and o.object_name   = i1.index_name
        
        --and ind$.obj#       = o.object_id
)
,ind as (
      select--+ no_merge
            i.*
           ,nvl( ip$.ts#   , i$.ts#   ) ts#
           ,nvl( ip$.file# , i$.file# ) file#
           ,nvl( ip$.block#, i$.block#) block#
           ,ip$.part#                   part#
      from ind1 i
          ,sys.ind$     i$
          ,sys.indpart$ ip$
      where  
            i$.obj# (+)     = i.OBJECT_ID
        and ip$.obj#(+)     = i.OBJECT_ID
)
,t as (
      select--+ no_merge(ind)
            ind.*
          , seg.blocks
      from 
           ind
          ,sys.seg$ seg
      where
            seg.ts#   (+) = ind.ts#
        and seg.file# (+) = ind.file#
        and seg.block#(+) = ind.block#
)
----------------------------------------------------
select/*+ opt_param('optimizer_use_feedback' 'false') */
   owner
  ,index_name
  ,nullif(uniqueness,'NONUNIQUE') uniq
  ,cols
  ,blevel
  ,leaf_blocks
  ,distinct_keys
  ,num_rows
  ,last_analyzed
  --------
  --,ts#,file#,block#
  ,(select ts$.name from sys.ts$ where ts$.ts#=t.ts#) tablespace_name
  ,object_id
  ,part#
  ,blocks
  ------
from t
order by index_name,object_id
/
col tablespace_name clear;
col uniq            clear
col cols            clear;
clear breaks;
