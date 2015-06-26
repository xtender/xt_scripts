accept _mask prompt "Mask[.*]: "
col feature for a35;
col path    for a100;
WITH feature_hierarchy AS (
   select 
      rownum n
     ,h.*
     ,substr(SYS_CONNECT_BY_PATH(REPLACE(h.sql_feature, 'QKSFM_'), ' -> '),5) path_concatenated
     ,rpad('  ',level*2,'..')||sql_feature                                    path_prefixed
   from v$sql_feature_hierarchy h
   start with
         sql_feature='QKSFM_ALL'
         --sql_feature='QKSFM_TRANSFORMATION'
         --parent_id is null
   connect by parent_id = prior sql_feature
)
select 
   fh.path_concatenated              as path
  ,REPLACE(fh.sql_feature, 'QKSFM_') as feature
  ,f.description
from feature_hierarchy fh
    ,v$sql_feature f
where ('&_mask' is null or regexp_like(path_concatenated,'&_mask','i'))
and f.SQL_FEATURE(+) = fh.sql_feature
order by n
/
col feature clear;
col path    clear;
undef _mask;