SELECT
  "A2"."OWNER" 
 ,"A2"."SEGMENT_NAME"
 ,DECODE(BITAND("A2"."SEGMENT_FLAGS",131072)
          ,131072,"A2"."BLOCKS"
          ,DECODE(BITAND("A2"."SEGMENT_FLAGS",1)
                   ,1,"SYS"."DBMS_SPACE_ADMIN"."SEGMENT_NUMBER_BLOCKS"( 
                               "A2"."TABLESPACE_ID"
                              ,"A2"."RELATIVE_FNO"
                              ,"A2"."HEADER_BLOCK"
                              ,"A2"."SEGMENT_TYPE_ID"
                              ,"A2"."BUFFER_POOL_ID"
                              ,"A2"."SEGMENT_FLAGS"
                              ,"A2"."SEGMENT_OBJD"
                              ,"A2"."BLOCKS"
                           )
                   ,"A2"."BLOCKS")
        )*"A2"."BLOCKSIZE" "BYTES" 
FROM  
( 
        SELECT 
             "A18"."NAME"                 "OWNER"
            ,"A17"."NAME"                 "SEGMENT_NAME"
            ,"A17"."SUBNAME"              "PARTITION_NAME"
            ,"A15"."OBJECT_TYPE"          "SEGMENT_TYPE"
            ,"A16"."BLOCKSIZE"            "BLOCKSIZE"

            ,"A14"."BLOCKS"*"A16"."BLOCKSIZE" "BYTES"
--            ,"A16"."NAME" "TABLESPACE_NAME"
            -- function params:
            ,"A16"."TS#"                  "TABLESPACE_ID"
            ,"A14"."FILE#"                "RELATIVE_FNO"
            ,"A14"."BLOCK#"               "HEADER_BLOCK"
            ,"A14"."TYPE#"                "SEGMENT_TYPE_ID"
            ,BITAND("A14"."CACHEHINT",3)  "BUFFER_POOL_ID"
            ,NVL("A14"."SPARE1",0) "SEGMENT_FLAGS"
            ,"A17"."DATAOBJ#" "SEGMENT_OBJD" 
            ,"A14"."BLOCKS" "BLOCKS"

       FROM "SYS"."USER$" "A18"
           ,"SYS"."OBJ$" "A17"
           ,"SYS"."TS$" "A16"
           ,( 
                       (SELECT DECODE("A25"."TYPE#",8,'LOBINDEX','INDEX') "OBJECT_TYPE",1 "OBJECT_TYPE_ID",6 "SEGMENT_TYPE_ID","A25"."OBJ#" "OBJECT_ID","A25"."FILE#" "HEADER_FILE","A25"."BLOCK#" "HEADER_BLOCK","A25"."TS#" "TS_NUMBER" FROM "SYS"."IND$" "A25" WHERE "A25"."TYPE#"=1 OR "A25"."TYPE#"=2 OR "A25"."TYPE#"=3 OR "A25"."TYPE#"=4 OR "A25"."TYPE#"=6 OR "A25"."TYPE#"=7 OR "A25"."TYPE#"=8 OR "A25"."TYPE#"=9) 
            UNION ALL  (SELECT 'INDEX PARTITION' "OBJECT_TYPE",20 "OBJECT_TYPE_ID",6 "SEGMENT_TYPE_ID","A24"."OBJ#" "OBJECT_ID","A24"."FILE#" "HEADER_FILE","A24"."BLOCK#" "HEADER_BLOCK","A24"."TS#" "TS_NUMBER" FROM "SYS"."INDPART$" "A24") 
            UNION ALL  (SELECT 'INDEX SUBPARTITION' "OBJECT_TYPE",35 "OBJECT_TYPE_ID",6 "SEGMENT_TYPE_ID","A21"."OBJ#" "OBJECT_ID","A21"."FILE#" "HEADER_FILE","A21"."BLOCK#" "HEADER_BLOCK","A21"."TS#" "TS_NUMBER" FROM "SYS"."INDSUBPART$" "A21") 
            ) "A15"
           ,"SYS"."SEG$" "A14"
       WHERE "A14"."FILE#" = "A15"."HEADER_FILE" 
       AND "A14"."BLOCK#"  = "A15"."HEADER_BLOCK" 
       AND "A14"."TS#"     = "A15"."TS_NUMBER" 
       AND "A14"."TS#"     = "A16"."TS#" 
       AND "A17"."OBJ#"    = "A15"."OBJECT_ID" 
       AND "A17"."OWNER#"  = "A18"."USER#"(+) 
       AND "A14"."TYPE#"   = "A15"."SEGMENT_TYPE_ID" 
       AND "A17"."TYPE#"   = "A15"."OBJECT_TYPE_ID" 
) "A2"
WHERE "A2"."OWNER"=:B1 AND "A2"."SEGMENT_NAME"=:B2
