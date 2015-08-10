accept _exp_schema prompt "Enter schema name: ";
spool exp_sysviews.~sql;
set feed on echo on;
create table &_exp_schema .DBA_VIEWS                    as select owner,view_name,to_lob(text) text  from DBA_VIEWS where owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_OBJECTS                  as select * from DBA_OBJECTS               where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TABLES                   as select * from DBA_TABLES                where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_INDEXES                  as select * from DBA_INDEXES               where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_IND_COLUMNS              as select * from DBA_IND_COLUMNS           where rownum=1 and index_owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_IND_STATISTICS           as select * from DBA_IND_STATISTICS        where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_SEGMENTS                 as select * from DBA_SEGMENTS              where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_DATA_FILES               as select * from DBA_DATA_FILES            where rownum=1 and 1=1;
create table &_exp_schema .DBA_PART_COL_STATISTICS      as select * from DBA_PART_COL_STATISTICS   where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_PART_HISTOGRAMS          as select * from DBA_PART_HISTOGRAMS       where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_PART_INDEXES             as select * from DBA_PART_INDEXES          where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_PART_KEY_COLUMNS         as select * from DBA_PART_KEY_COLUMNS      where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_PART_TABLES              as select * from DBA_PART_TABLES           where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_PLSQL_OBJECT_SETTINGS    as select * from DBA_PLSQL_OBJECT_SETTINGS where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_PROCEDURES               as select * from DBA_PROCEDURES            where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_SQL_PROFILES             as select * from DBA_SQL_PROFILES          where rownum=1 and 1=1;
create table &_exp_schema .DBA_STAT_EXTENSIONS          as select * from DBA_STAT_EXTENSIONS       where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TABLESPACES              as select * from DBA_TABLESPACES           where rownum=1 and 1=1;
create table &_exp_schema .DBA_TAB_COL_STATISTICS       as select * from DBA_TAB_COL_STATISTICS    where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TAB_HISTOGRAMS           as select * from DBA_TAB_HISTOGRAMS        where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TAB_MODIFICATIONS        as select * from DBA_TAB_MODIFICATIONS     where rownum=1 and table_owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TAB_STATISTICS           as select * from DBA_TAB_STATISTICS        where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TAB_STAT_PREFS           as select * from DBA_TAB_STAT_PREFS        where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TEMP_FILES               as select * from DBA_TEMP_FILES            where rownum=1 and 1=1;
create table &_exp_schema .DBA_TEMP_FREE_SPACE          as select * from DBA_TEMP_FREE_SPACE       where rownum=1 and 1=1;
create table &_exp_schema .DBA_TRIGGER_COLS             as select * from DBA_TRIGGER_COLS          where rownum=1 and table_owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TYPES                    as select * from DBA_TYPES                 where rownum=1 and owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TAB_COLUMNS as 
         select 
          OWNER,TABLE_NAME,COLUMN_NAME,DATA_TYPE,DATA_TYPE_MOD,DATA_TYPE_OWNER,DATA_LENGTH,DATA_PRECISION
         ,DATA_SCALE,NULLABLE,COLUMN_ID,DEFAULT_LENGTH,to_lob(DATA_DEFAULT) as DATA_DEFAULT,NUM_DISTINCT
         ,LOW_VALUE,HIGH_VALUE,DENSITY,NUM_NULLS,NUM_BUCKETS,LAST_ANALYZED,SAMPLE_SIZE,CHARACTER_SET_NAME
         ,CHAR_COL_DECL_LENGTH,GLOBAL_STATS,USER_STATS,AVG_COL_LEN,CHAR_LENGTH,CHAR_USED,V80_FMT_IMAGE
         ,DATA_UPGRADED,HISTOGRAM 
         from DBA_TAB_COLUMNS
         where owner not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_IND_PARTITIONS as
         select
          INDEX_OWNER,INDEX_NAME,COMPOSITE,PARTITION_NAME,SUBPARTITION_COUNT,to_lob(HIGH_VALUE) as HIGH_VALUE
         ,HIGH_VALUE_LENGTH,PARTITION_POSITION,STATUS,TABLESPACE_NAME,PCT_FREE,INI_TRANS,MAX_TRANS,INITIAL_EXTENT
         ,NEXT_EXTENT,MIN_EXTENT,MAX_EXTENT,PCT_INCREASE,FREELISTS,FREELIST_GROUPS,LOGGING,COMPRESSION
         ,BLEVEL,LEAF_BLOCKS,DISTINCT_KEYS,AVG_LEAF_BLOCKS_PER_KEY,AVG_DATA_BLOCKS_PER_KEY
         ,CLUSTERING_FACTOR,NUM_ROWS,SAMPLE_SIZE,LAST_ANALYZED,BUFFER_POOL,USER_STATS,PCT_DIRECT_ACCESS
         ,GLOBAL_STATS,DOMIDX_OPSTATUS,PARAMETERS
         from DBA_IND_PARTITIONS
         where INDEX_OWNER not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_IND_EXPRESSIONS as
         select
          INDEX_OWNER,INDEX_NAME,TABLE_OWNER,TABLE_NAME,to_lob(COLUMN_EXPRESSION) as COLUMN_EXPRESSION,COLUMN_POSITION
         from DBA_IND_EXPRESSIONS
         where INDEX_OWNER not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_IND_SUBPARTITIONS as
         select
          INDEX_OWNER,INDEX_NAME,PARTITION_NAME,SUBPARTITION_NAME,to_lob(HIGH_VALUE) as HIGH_VALUE
         ,HIGH_VALUE_LENGTH,SUBPARTITION_POSITION,STATUS,TABLESPACE_NAME,PCT_FREE,INI_TRANS,MAX_TRANS
         ,INITIAL_EXTENT,NEXT_EXTENT,MIN_EXTENT,MAX_EXTENT,PCT_INCREASE,FREELISTS,FREELIST_GROUPS
         ,LOGGING,COMPRESSION,BLEVEL,LEAF_BLOCKS,DISTINCT_KEYS,AVG_LEAF_BLOCKS_PER_KEY,AVG_DATA_BLOCKS_PER_KEY
         ,CLUSTERING_FACTOR,NUM_ROWS,SAMPLE_SIZE,LAST_ANALYZED,BUFFER_POOL,USER_STATS,GLOBAL_STATS
         from DBA_IND_SUBPARTITIONS
         where INDEX_OWNER not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TAB_COLS as
         select
          OWNER,TABLE_NAME,COLUMN_NAME,DATA_TYPE,DATA_TYPE_MOD,DATA_TYPE_OWNER,DATA_LENGTH,DATA_PRECISION,DATA_SCALE
         ,NULLABLE,COLUMN_ID,DEFAULT_LENGTH,to_lob(DATA_DEFAULT) as DATA_DEFAULT,NUM_DISTINCT,LOW_VALUE,HIGH_VALUE
         ,DENSITY,NUM_NULLS,NUM_BUCKETS,LAST_ANALYZED,SAMPLE_SIZE,CHARACTER_SET_NAME,CHAR_COL_DECL_LENGTH
         ,GLOBAL_STATS,USER_STATS,AVG_COL_LEN,CHAR_LENGTH,CHAR_USED,V80_FMT_IMAGE,DATA_UPGRADED
         ,HIDDEN_COLUMN,VIRTUAL_COLUMN,SEGMENT_COLUMN_ID,INTERNAL_COLUMN_ID,HISTOGRAM,QUALIFIED_COL_NAME
         from DBA_TAB_COLS
         where OWNER not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TAB_PARTITIONS as
         select
          TABLE_OWNER,TABLE_NAME,COMPOSITE,PARTITION_NAME,SUBPARTITION_COUNT,to_lob(HIGH_VALUE) as HIGH_VALUE
         ,HIGH_VALUE_LENGTH,PARTITION_POSITION,TABLESPACE_NAME,PCT_FREE,PCT_USED,INI_TRANS,MAX_TRANS,INITIAL_EXTENT
         ,NEXT_EXTENT,MIN_EXTENT,MAX_EXTENT,PCT_INCREASE,FREELISTS,FREELIST_GROUPS,LOGGING,COMPRESSION,NUM_ROWS
         ,BLOCKS,EMPTY_BLOCKS,AVG_SPACE,CHAIN_CNT,AVG_ROW_LEN,SAMPLE_SIZE,LAST_ANALYZED,BUFFER_POOL,GLOBAL_STATS,USER_STATS
         from DBA_TAB_PARTITIONS
         where TABLE_OWNER not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TAB_SUBPARTITIONS as
         select
          TABLE_OWNER,TABLE_NAME,PARTITION_NAME,SUBPARTITION_NAME,to_lob(HIGH_VALUE) as HIGH_VALUE,HIGH_VALUE_LENGTH
         ,SUBPARTITION_POSITION,TABLESPACE_NAME,PCT_FREE,PCT_USED,INI_TRANS,MAX_TRANS,INITIAL_EXTENT,NEXT_EXTENT
         ,MIN_EXTENT,MAX_EXTENT,PCT_INCREASE,FREELISTS,FREELIST_GROUPS,LOGGING,COMPRESSION,NUM_ROWS,BLOCKS
         ,EMPTY_BLOCKS,AVG_SPACE,CHAIN_CNT,AVG_ROW_LEN,SAMPLE_SIZE,LAST_ANALYZED,BUFFER_POOL,GLOBAL_STATS,USER_STATS
         from DBA_TAB_SUBPARTITIONS
         where TABLE_OWNER not in ('SYS','SYSTEM');
create table &_exp_schema .DBA_TRIGGERS as
         select
          OWNER,TRIGGER_NAME,TRIGGER_TYPE,TRIGGERING_EVENT,TABLE_OWNER,BASE_OBJECT_TYPE,TABLE_NAME
         ,COLUMN_NAME,REFERENCING_NAMES,WHEN_CLAUSE,STATUS,DESCRIPTION,ACTION_TYPE,to_lob(TRIGGER_BODY) as TRIGGER_BODY
         from DBA_TRIGGERS
         where OWNER not in ('SYS','SYSTEM');



create table &_exp_schema .GV$ACTIVE_INSTANCES          as select * from GV$ACTIVE_INSTANCES         ;
create table &_exp_schema .GV$ACTIVE_SERVICES           as select * from GV$ACTIVE_SERVICES          ;
create table &_exp_schema .GV$ARCHIVE_DEST              as select * from GV$ARCHIVE_DEST             ;
create table &_exp_schema .GV$DATABASE                  as select * from GV$DATABASE                 ;
create table &_exp_schema .GV$DATAFILE                  as select * from GV$DATAFILE                 ;
create table &_exp_schema .GV$DB_OBJECT_CACHE           as select * from GV$DB_OBJECT_CACHE          ;
create table &_exp_schema .GV$DIAG_INFO                 as select * from GV$DIAG_INFO                ;
create table &_exp_schema .GV$EVENT_HISTOGRAM           as select * from GV$EVENT_HISTOGRAM          ;
create table &_exp_schema .GV$IOSTAT_FILE               as select * from GV$IOSTAT_FILE              ;
create table &_exp_schema .GV$IOSTAT_FUNCTION           as select * from GV$IOSTAT_FUNCTION          ;
create table &_exp_schema .GV$IOSTAT_FUNCTION_DETAIL    as select * from GV$IOSTAT_FUNCTION_DETAIL   ;
create table &_exp_schema .GV$LIBRARYCACHE              as select * from GV$LIBRARYCACHE             ;
create table &_exp_schema .GV$LIBRARY_CACHE_MEMORY      as select * from GV$LIBRARY_CACHE_MEMORY     ;
create table &_exp_schema .GV$LOG                       as select * from GV$LOG                      ;
create table &_exp_schema .GV$LOGFILE                   as select * from GV$LOGFILE                  ;
create table &_exp_schema .GV$LOG_HISTORY               as select * from GV$LOG_HISTORY              ;
create table &_exp_schema .GV$OSSTAT                    as select * from GV$OSSTAT                   ;
create table &_exp_schema .GV$MEMORY_DYNAMIC_COMPONENTS as select * from GV$MEMORY_DYNAMIC_COMPONENTS;
create table &_exp_schema .GV$PARAMETER                 as select * from GV$PARAMETER                ;
create table &_exp_schema .GV$RESULT_CACHE_STATISTICS   as select * from GV$RESULT_CACHE_STATISTICS  ;
create table &_exp_schema .GV$SPPARAMETER               as select * from GV$SPPARAMETER              ;
create table &_exp_schema .GV$SYSMETRIC                 as select * from GV$SYSMETRIC                ;
create table &_exp_schema .GV$SYSMETRIC_SUMMARY         as select * from GV$SYSMETRIC_SUMMARY        ;
create table &_exp_schema .GV$SYSTEM_PARAMETER          as select * from GV$SYSTEM_PARAMETER         ;
create table &_exp_schema .GV$SYSTEM_FIX_CONTROL        as select * from GV$SYSTEM_FIX_CONTROL       ;
create table &_exp_schema .GV$SYS_OPTIMIZER_ENV         as select * from GV$SYS_OPTIMIZER_ENV        ;
create table &_exp_schema .GV$VERSION                   as select * from GV$VERSION                  ;
create table &_exp_schema .GV$ACTIVE_SESSION_HISTORY    as select * from GV$ACTIVE_SESSION_HISTORY   ;
spool off;
set echo off;
undef _exp_schema;
