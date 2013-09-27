col structure format a15;
col function  format a20;
with t as (
      select--+ leading(cur hp) use_nl(cur hp) no_merge
            cur.INST_ID  as INST_ID 
           ,cur.KGLNAOBJ as SQL_TEXT 
           ,cur.KGLFNOBJ as SQL_FULLTEXT 
           ,cur.KGLNAHSH as HASH_VALUE 
           ,cur.KGLOBT03 as SQL_ID 
           ,cur.KGLOBHD6 as HEAP_DESC 
           ,RTRIM(SUBSTR(hp.KSMCHCOM 
                        ,1 
                        ,INSTR(hp.KSMCHCOM, ':', 1, 1) - 1) 
                 ) 
                  as STRUCTURE 
           ,LTRIM(SUBSTR(hp.KSMCHCOM 
                        ,(- (LENGTH(hp.KSMCHCOM) - 
                         INSTR(hp.KSMCHCOM, ':', 1, 1))) 
                        ,LENGTH(hp.KSMCHCOM) - 
                        INSTR(hp.KSMCHCOM, ':', 1, 1) + 1) 
                 ) 
                  as FUNCTION 
           ,hp.KSMCHCOM as CHUNK_COM 
           ,hp.KSMCHPTR as CHUNK_PTR 
           ,hp.KSMCHSIZ as CHUNK_SIZE 
           ,hp.KSMCHCLS as ALLOC_CLASS 
           ,hp.KSMCHTYP as CHUNK_TYPE 
           ,hp.KSMCHPAR as SUBHEAP_DESC 
      from
            sys.x$kglcursor cur
          , sys.x$ksmhp hp 
      where
            hp.KSMCHDS    = cur.KGLOBHD6 
      and   cur.KGLHDADR != cur.KGLHDPAR 
      and   cur.INST_ID   = USERENV('INSTANCE') 
      and   cur.KGLOBT03  = '&1'
)
select heap_desc,structure,function,chunk_com,alloc_class,chunk_type,subheap_desc
      ,sum(CHUNK_SIZE),count(*)
from t
group by HEAP_DESC,STRUCTURE,FUNCTION,CHUNK_COM,ALLOC_CLASS,CHUNK_TYPE,SUBHEAP_DESC
order by sum(CHUNK_SIZE) desc
/
col structure clear;
col function  clear;
