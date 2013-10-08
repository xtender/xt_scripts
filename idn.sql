col OBJECT     format a30;
col fn_obj     format a150;
col namespace  format a20;
col type       format a12;
col ftype      format a15;
col status     format a7;
col PREVIOUS_TIMESTAMP format a12;
SELECT 
        kgl_ob.kglnaown    owner
       ,kgl_ob.KGLNAOBJ    object
--       ,kgl_ob.KGLFNOBJ    fn_obj
       ,decode( kgl_ob.kglhdnsp
                   ,0,'CURSOR'
                   ,1   ,'TABLE / PROCEDURE'
                   ,2   ,'BODY'
                   ,3   ,'TRIGGER'
                   ,4   ,'INDEX'
                   ,5   ,'CLUSTER'
                   ,6   ,'OBJECT'
                   ,13  ,'JAVA SOURCE'
                   ,14  ,'JAVA RESOURCE'
                   ,15  ,'REPLICATED TABLE OBJECT'
                   ,16  ,'REPLICATION INTERNAL PACKAGE'
                   ,17  ,'CONTEXT POLICY'
                   ,18  ,'PUB_SUB'
                   ,19  ,'SUMMARY'
                   ,20  ,'DIMENSION'
                   ,21  ,'APP CONTEXT'
                   ,22  ,'STORED OUTLINE'
                   ,23  ,'RULESET'
                   ,24  ,'RSRC PLAN'
                   ,25  ,'RSRC CONSUMER GROUP'
                   ,26  ,'PENDING RSRC PLAN'
                   ,27  ,'PENDING RSRC CONSUMER GROUP'
                   ,28  ,'SUBSCRIPTION'
                   ,29  ,'LOCATION'
                   ,30  ,'REMOTE OBJECT'
                   ,31  ,'SNAPSHOT METADATA'
                   ,32  ,'JAVA SHARED DATA'
                   ,33  ,'SECURITY PROFILE'
                   ,'INVALID NAMESPACE'
       ) as namespace
       , decode( kgl_ob.kglobtyp, 
                        0, 'CURSOR'                , 1, 'INDEX'                 , 2, 'TABLE'
                      , 3, 'CLUSTER'               , 4, 'VIEW'                  , 5, 'SYNONYM'
                      , 6, 'SEQUENCE'              , 7, 'PROCEDURE'             , 8, 'FUNCTION'
                      , 9, 'PACKAGE'               , 10,'NON-EXISTENT'          , 11,'PACKAGE BODY'
                      , 12,'TRIGGER'               , 13,'TYPE'                  , 14,'TYPE BODY'
                      , 15,'OBJECT'                , 16,'USER'                  , 17,'DBLINK'
                      , 18,'PIPE'                  , 19,'TABLE PARTITION'       , 20,'INDEX PARTITION'
                      , 21,'LOB'                   , 22,'LIBRARY'               , 23,'DIRECTORY'
                      , 24,'QUEUE'                 , 25,'INDEX-ORGANIZED TABLE' , 26,'REPLICATION OBJECT GROUP'
                      , 27,'REPLICATION PROPAGATOR', 28,'JAVA SOURCE'           , 29,'JAVA CLASS'
                      , 30,'JAVA RESOURCE'         , 31,'JAVA JAR'
                   , 'INVALID TYPE:'||kgl_ob.KGLOBTYP
        ) as type
       ,decode(bitand(kglobflg, 3)
                 , 0, 'NOT LOADED'
                 , 2, 'NON - EXISTENT'
                 , 3, 'INVALID STATUS'
                 , decode( kgl_ob.kglobtyp, 
                                 0, 'CURSOR'                , 1, 'INDEX'                 , 2, 'TABLE'
                               , 3, 'CLUSTER'               , 4, 'VIEW'                  , 5, 'SYNONYM'
                               , 6, 'SEQUENCE'              , 7, 'PROCEDURE'             , 8, 'FUNCTION'
                               , 9, 'PACKAGE'               , 10,'NON-EXISTENT'          , 11,'PACKAGE BODY'
                               , 12,'TRIGGER'               , 13,'TYPE'                  , 14,'TYPE BODY'
                               , 15,'OBJECT'                , 16,'USER'                  , 17,'DBLINK'
                               , 18,'PIPE'                  , 19,'TABLE PARTITION'       , 20,'INDEX PARTITION'
                               , 21,'LOB'                   , 22,'LIBRARY'               , 23,'DIRECTORY'
                               , 24,'QUEUE'                 , 25,'INDEX-ORGANIZED TABLE' , 26,'REPLICATION OBJECT GROUP'
                               , 27,'REPLICATION PROPAGATOR', 28,'JAVA SOURCE'           , 29,'JAVA CLASS'
                               , 30,'JAVA RESOURCE'         , 31,'JAVA JAR'
                            , 'INVALID TYPE:'||kgl_ob.KGLOBTYP
                  )
        ) as ftype
       ,kglobhs0+kglobhs1+kglobhs2+kglobhs3+kglobhs4+kglobhs5+kglobhs6 as SHARABLE_MEM
       ,kglhdldc                                                       as LOADS 
       ,kglhdexc                                                       as EXECUT
       ,kglhdlkc                                                       as LOCKS 
       ,kglobpc0                                                       as PINS  
       ,decode(kglhdkmk,0,'NO',' YES')                                 as KEPT  
       ,kglhdclt                                                       as CHILD_LATCH
       ,kglhdivc                                                       as INVALIDATIONS
       ,DECODE(KGLHDLMD
                  ,0   ,'NONE'
                  ,1   ,'NULL'
                  ,2   ,'SHARED'
                  ,3   ,'EXCLUSIVE'
                  ,'UNKOWN')                                           as LOCK_MODE
       ,DECODE(KGLHDPMD
                  ,0   ,'NONE'
                  ,1   ,'NULL'
                  ,2   ,'SHARED'
                  ,3   ,'EXCLUSIVE'
                  ,'UNKOWN')                                           as PIN_MODE
       ,DECODE(KGLOBSTA
                  ,1   ,'VALID'
                  ,2   ,'VALID_AUTH_ERROR'
                  ,3   ,'VALID_COMPILE_ERROR'
                  ,4   ,'VALID_UNAUTH'
                  ,5   ,'INVALID_UNAUTH'
                  ,6   ,'INVALID'
                  ,'UNKOWN')                                           as STATUS
       ,SUBSTR(TO_CHAR(KGLNATIM,'YYYY-MM-DD/HH24:MI:SS'),1,19)         as "TIMESTAMP"
       ,SUBSTR(TO_CHAR(KGLNAPTM,'YYYY-MM-DD/HH24:MI:SS'),1,19)         as "PREVIOUS_TIMESTAMP"
       ,KGLOBT23                                                       as LOCKED_TOTAL
       ,KGLOBT24                                                       as PINNED_TOTAL
--       ,KGLOBPROP                                                      as PROPERTY
       ,KGLNAHSV                                                       as FULL_HASH_VALUE
       ,kgl_ob.KGLFNOBJ    fn_obj
FROM   
        vx$kglob kgl_ob
WHERE  
        kgl_ob.kglnahsh = &1
AND    (kgl_ob.kglhdadr = kgl_ob.kglhdpar)
and    rownum = 1
/
