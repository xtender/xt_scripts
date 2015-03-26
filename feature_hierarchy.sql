accept _mask prompt "Mask[.*]: "
col feature for a35;
col path    for a100;
WITH feature_hierarchy AS (
   select
      rownum n
     ,f.sql_feature
     ,substr(SYS_CONNECT_BY_PATH(REPLACE(f.sql_feature, 'QKSFM_'), ' -> '),5) path
   FROM 
       v$sql_feature f
     , v$sql_feature_hierarchy fh 
   WHERE 
       f.sql_feature = fh.sql_feature 
   CONNECT BY fh.parent_id = PRIOR f.sql_Feature 
   START WITH fh.sql_feature = 'QKSFM_ALL'
)
select 
   fh.path
  ,REPLACE(fh.sql_feature, 'QKSFM_') as feature
from feature_hierarchy fh
where '&_mask' is null or regexp_like(path,'&_mask','i')
order by n
/
col feature clear;
col path    clear;
undef _mask;