SELECT "A1"."BYTES" "BYTES" 
FROM  
       (
       SELECT "A2"."OWNER" "OWNER"
             ,"A2"."SEGMENT_NAME" "SEGMENT_NAME"
             ,DECODE(BITAND("A2"."SEGMENT_FLAGS",131072)
                      ,131072,"A2"."BLOCKS"
                      ,DECODE(BITAND("A2"."SEGMENT_FLAGS",1)
                               ,1,"SYS"."DBMS_SPACE_ADMIN"."SEGMENT_NUMBER_BLOCKS"( "A2"."TABLESPACE_ID","A2"."RELATIVE_FNO","A2"."HEADER_BLOCK","A2"."SEGMENT_TYPE_ID","A2"."BUFFER_POOL_ID","A2"."SEGMENT_FLAGS","A2"."SEGMENT_OBJD","A2"."BLOCKS")
                               ,"A2"."BLOCKS")
                    )*"A2"."BLOCKSIZE" "BYTES" 
       FROM  
          ( 
                 (
                    SELECT 
                        NVL("A18"."NAME",'SYS') "OWNER"
                        ,"A17"."NAME" "SEGMENT_NAME"
                        ,"A17"."SUBNAME" "PARTITION_NAME"
                        ,"A15"."OBJECT_TYPE" "SEGMENT_TYPE"
                        ,"A14"."TYPE#" "SEGMENT_TYPE_ID"
                        ,DECODE(BITAND("A14"."SPARE1",2097408),2097152,'SECUREFILE',256,'ASSM','MSSM') "SEGMENT_SUBTYPE"
                        ,"A16"."TS#" "TABLESPACE_ID","A16"."NAME" "TABLESPACE_NAME"
                        ,"A16"."BLOCKSIZE" "BLOCKSIZE"
                        ,"A13"."FILE#" "HEADER_FILE"
                        ,"A14"."BLOCK#" "HEADER_BLOCK"
                        ,"A14"."BLOCKS"*"A16"."BLOCKSIZE" "BYTES"
                        ,"A14"."BLOCKS" "BLOCKS"
                        ,"A14"."EXTENTS" "EXTENTS"
                        ,"A14"."INIEXTS"*"A16"."BLOCKSIZE" "INITIAL_EXTENT"
                        ,"A14"."EXTSIZE"*"A16"."BLOCKSIZE" "NEXT_EXTENT"
                        ,"A14"."MINEXTS" "MIN_EXTENTS"
                        ,"A14"."MAXEXTS" "MAX_EXTENTS"
                        ,DECODE(BITAND("A14"."SPARE1",4194304),4194304,"A14"."BITMAPRANGES",NULL) "MAX_SIZE"
                        ,TO_CHAR(DECODE(BITAND("A14"."SPARE1",2097152),2097152,DECODE("A14"."LISTS",0,'NONE',1,'AUTO',2,'MIN',3,'MAX',4,'DEFAULT','INVALID'),NULL)) "RETENTION"
                        ,DECODE(BITAND("A14"."SPARE1",2097152),2097152,"A14"."GROUPS",NULL) "MINRETENTION"
                        ,DECODE(BITAND("A16"."FLAGS",3),1,TO_NUMBER(NULL),"A14"."EXTPCT") "PCT_INCREASE"
                        ,DECODE(BITAND("A16"."FLAGS",32),32,TO_NUMBER(NULL),DECODE("A14"."LISTS",0,1,"A14"."LISTS")) "FREELISTS"
                        ,DECODE(BITAND("A16"."FLAGS",32),32,TO_NUMBER(NULL),DECODE("A14"."GROUPS",0,1,"A14"."GROUPS")) "FREELIST_GROUPS"
                        ,"A14"."FILE#" "RELATIVE_FNO"
                        ,BITAND("A14"."CACHEHINT",3) "BUFFER_POOL_ID"
                        ,BITAND("A14"."CACHEHINT",12)/4 "FLASH_CACHE"
                        ,BITAND("A14"."CACHEHINT",48)/16 "CELL_FLASH_CACHE"
                        ,NVL("A14"."SPARE1",0) "SEGMENT_FLAGS"
                        ,"A17"."DATAOBJ#" "SEGMENT_OBJD" 
                   FROM "SYS"."USER$" "A18"
                       ,"SYS"."OBJ$" "A17"
                       ,"SYS"."TS$" "A16"
                       ,( 
                                   (SELECT DECODE(BITAND("A28"."PROPERTY",8192),8192,'NESTED TABLE','TABLE') "OBJECT_TYPE",2 "OBJECT_TYPE_ID",5 "SEGMENT_TYPE_ID","A28"."OBJ#" "OBJECT_ID","A28"."FILE#" "HEADER_FILE","A28"."BLOCK#" "HEADER_BLOCK","A28"."TS#" "TS_NUMBER" FROM "SYS"."TAB$" "A28" WHERE BITAND("A28"."PROPERTY",1024)=0) 
                        UNION ALL  (SELECT 'TABLE PARTITION' "OBJECT_TYPE",19 "OBJECT_TYPE_ID",5 "SEGMENT_TYPE_ID","A27"."OBJ#" "OBJECT_ID","A27"."FILE#" "HEADER_FILE","A27"."BLOCK#" "HEADER_BLOCK","A27"."TS#" "TS_NUMBER" FROM "SYS"."TABPART$" "A27") 
                        UNION ALL  (SELECT 'CLUSTER' "OBJECT_TYPE",3 "OBJECT_TYPE_ID",5 "SEGMENT_TYPE_ID","A26"."OBJ#" "OBJECT_ID","A26"."FILE#" "HEADER_FILE","A26"."BLOCK#" "HEADER_BLOCK","A26"."TS#" "TS_NUMBER" FROM "SYS"."CLU$" "A26") 
                        UNION ALL  (SELECT DECODE("A25"."TYPE#",8,'LOBINDEX','INDEX') "OBJECT_TYPE",1 "OBJECT_TYPE_ID",6 "SEGMENT_TYPE_ID","A25"."OBJ#" "OBJECT_ID","A25"."FILE#" "HEADER_FILE","A25"."BLOCK#" "HEADER_BLOCK","A25"."TS#" "TS_NUMBER" FROM "SYS"."IND$" "A25" WHERE "A25"."TYPE#"=1 OR "A25"."TYPE#"=2 OR "A25"."TYPE#"=3 OR "A25"."TYPE#"=4 OR "A25"."TYPE#"=6 OR "A25"."TYPE#"=7 OR "A25"."TYPE#"=8 OR "A25"."TYPE#"=9) 
                        UNION ALL  (SELECT 'INDEX PARTITION' "OBJECT_TYPE",20 "OBJECT_TYPE_ID",6 "SEGMENT_TYPE_ID","A24"."OBJ#" "OBJECT_ID","A24"."FILE#" "HEADER_FILE","A24"."BLOCK#" "HEADER_BLOCK","A24"."TS#" "TS_NUMBER" FROM "SYS"."INDPART$" "A24") 
                        UNION ALL  (SELECT 'LOBSEGMENT' "OBJECT_TYPE",21 "OBJECT_TYPE_ID",8 "SEGMENT_TYPE_ID","A23"."LOBJ#" "OBJECT_ID","A23"."FILE#" "HEADER_FILE","A23"."BLOCK#" "HEADER_BLOCK","A23"."TS#" "TS_NUMBER" FROM "SYS"."LOB$" "A23" WHERE BITAND("A23"."PROPERTY",64)=0 OR BITAND("A23"."PROPERTY",128)=128) 
                        UNION ALL  (SELECT 'TABLE SUBPARTITION' "OBJECT_TYPE",34 "OBJECT_TYPE_ID",5 "SEGMENT_TYPE_ID","A22"."OBJ#" "OBJECT_ID","A22"."FILE#" "HEADER_FILE","A22"."BLOCK#" "HEADER_BLOCK","A22"."TS#" "TS_NUMBER" FROM "SYS"."TABSUBPART$" "A22") 
                        UNION ALL  (SELECT 'INDEX SUBPARTITION' "OBJECT_TYPE",35 "OBJECT_TYPE_ID",6 "SEGMENT_TYPE_ID","A21"."OBJ#" "OBJECT_ID","A21"."FILE#" "HEADER_FILE","A21"."BLOCK#" "HEADER_BLOCK","A21"."TS#" "TS_NUMBER" FROM "SYS"."INDSUBPART$" "A21") 
                        UNION ALL  (SELECT DECODE("A20"."FRAGTYPE$",'P','LOB PARTITION','LOB SUBPARTITION') "OBJECT_TYPE",DECODE("A20"."FRAGTYPE$",'P',40,41) "OBJECT_TYPE_ID",8 "SEGMENT_TYPE_ID","A20"."FRAGOBJ#" "OBJECT_ID","A20"."FILE#" "HEADER_FILE","A20"."BLOCK#" "HEADER_BLOCK","A20"."TS#" "TS_NUMBER" FROM "SYS"."LOBFRAG$" "A20")
                        ) "A15"
                       ,"SYS"."SEG$" "A14"
                       ,"SYS"."FILE$" "A13" 
                   WHERE "A14"."FILE#"="A15"."HEADER_FILE" 
                   AND "A14"."BLOCK#"="A15"."HEADER_BLOCK" 
                   AND "A14"."TS#"="A15"."TS_NUMBER" 
                   AND "A14"."TS#"="A16"."TS#" 
                   AND "A17"."OBJ#"="A15"."OBJECT_ID" 
                   AND "A17"."OWNER#"="A18"."USER#"(+) 
                   AND "A14"."TYPE#"="A15"."SEGMENT_TYPE_ID" 
                   AND "A17"."TYPE#"="A15"."OBJECT_TYPE_ID" 
                   AND "A14"."TS#"="A13"."TS#" 
                   AND "A14"."FILE#"="A13"."RELFILE#"
                  ) 

          ) "A2"
      ) "A1" WHERE "A1"."OWNER"=:B1 AND "A1"."SEGMENT_NAME"=:B2
