@inc/input_vars_init.sql

with xt_v$sql_shared_memory as (
      SELECT *
      FROM   (select/*+ ordered use_nl(h c) no_merge */
               c.inst_id                                                                INST_ID    
              ,kglnaobj                                                                 SQL_TEXT
              ,kglfnobj                                                                 SQL_FULLTEXT  
              ,kglnahsh                                                                 HASH_VALUE      
              ,kglobt03                                                                 SQL_ID   
              ,kglobhd6                                                                 HEAP_DESC
              ,rtrim(substr(ksmchcom, 1, instr(ksmchcom, ' :', 1, 1)-1))               "STRUCTURE"
              ,ltrim(substr(ksmchcom                                                    
                           ,- (length(ksmchcom) - (instr(ksmchcom, ' :', 1, 1)))        
                           ,(length(ksmchcom) -(instr(ksmchcom, ' :', 1, 1)) + 1)))     "FUNCTION"   
              ,ksmchcom                                                                 CHUNK_COM   
              ,ksmchptr                                                                 CHUNK_PTR  
              ,ksmchsiz                                                                 CHUNK_SIZE 
              ,ksmchcls                                                                 ALLOC_CLASS  
              ,ksmchtyp                                                                 CHUNK_TYPE
              ,ksmchpar                                                                 SUBHEAP_DESC
              from   sys.x$kglcursor c, sys.x$ksmhp h
              where  
                     ksmchds   = kglobhd6
              and    kglhdadr != kglhdpar
              and    c.inst_id = USERENV('INSTANCE')
              and    kglobt03  = '&1'
             )
) -------------
select 
--*
--/*
    chunk_com, 
    alloc_class, 
    sum(chunk_size) totsize,
    count(*),
    count (distinct chunk_size) diff_sizes,
    round(avg(chunk_size)) avgsz,
    min(chunk_size) minsz,
    max(chunk_size) maxsz
--*/
from xt_v$sql_shared_memory sm
where 1=1
--/*
GROUP BY
    chunk_com,
    alloc_class
ORDER BY
    totsize DESC   
--*/
/
@inc/input_vars_undef.sql