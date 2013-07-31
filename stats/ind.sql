@inc/input_vars_init.sql

column DESCRIPTION                  for a37
column PARTITION_NAME               for a20
column PARTITION_POSITION           for 999
column SUBPARTITION_NAME            for a20
column SUBPARTITION_POSITION        for 999
column OBJECT_TYPE                  for a12

column BLEVEL                       for 99
--column LEAF_BLOCKS                                        NUMBER
--column DISTINCT_KEYS                                      NUMBER
--column AVG_LEAF_BLOCKS_PER_KEY                            NUMBER
--column AVG_DATA_BLOCKS_PER_KEY                            NUMBER
--column CLUSTERING_FACTOR                                  NUMBER
--column NUM_ROWS                                           NUMBER
--column AVG_CACHED_BLOCKS                                  NUMBER
--column AVG_CACHE_HIT_RATIO                                NUMBER
--column SAMPLE_SIZE                                        NUMBER
--column LAST_ANALYZED                                      DATE

column GLOBAL_STATS     heading glob_st for a3;
column USER_STATS       heading usr_st  for a5;
column STATTYPE_LOCKED  heading locked  for a5;
column STALE_STATS                      for a3;

break on description skip 1
select 
       decode(dd.q
               ,0 , 'Table: '||ii.TABLE_OWNER||'.'||ii.TABLE_NAME||':'
               ,1 , '   '||st.OWNER||'.'||st.INDEX_NAME
               )
        description
     , st.LAST_ANALYZED
     , st.PARTITION_NAME       
     , st.PARTITION_POSITION   p_pos
--     , SUBPARTITION_NAME    
--     , SUBPARTITION_POSITION
     , st.OBJECT_TYPE          
     , st.BLEVEL                 
     , st.LEAF_BLOCKS            
     , st.DISTINCT_KEYS          
     , st.AVG_LEAF_BLOCKS_PER_KEY avg_lf_pk
     , st.AVG_DATA_BLOCKS_PER_KEY avg_dat_pk
     , st.CLUSTERING_FACTOR       cl_factor
     , st.NUM_ROWS               
     , st.SAMPLE_SIZE
     , st.GLOBAL_STATS
     , st.USER_STATS
     , st.STATTYPE_LOCKED
     , st.STALE_STATS
     , st.AVG_CACHED_BLOCKS       cached
     , st.AVG_CACHE_HIT_RATIO     hit_ratio
from 
     (select i.TABLE_OWNER,i.table_name,i.owner,i.index_name
      from dba_indexes i
      where 
            i.index_name like upper('&1') escape '\'
        and i.owner      like nvl(upper('&2'),'%') escape '\'
     ) ii
    join (select 0 q from dual union all select 1 q from dual) dd
         on 1=1 
    left join dba_ind_statistics st 
         on  dd.q  = 1
         and st.owner      = ii.owner
         and st.index_name = ii.index_name
order by ii.owner,ii.index_name,dd.q,decode(st.OBJECT_TYPE,'INDEX',1,2),st.partition_position
/
@inc/input_vars_undef.sql
