accept _path_mask prompt "Path mask[.*]: " default '.*';
accept _hint_mask prompt "Hint mask[.*]: " default '.*';
accept _min_ver   prompt "Min version: "   default '';

col path        for a100;
col hint_class  for a30;
col hint_name   for a30;
col version     for a8;
col ver_outline for a8;

WITH feature_hierarchy AS (
   select--+ no_merge
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
select fh.path
      ,hi.class           as hint_class
      ,hi.name            as hint_name
      ,hi.version         as version
      ,hi.version_outline as ver_outline
from feature_hierarchy fh
    ,v$sql_hint hi
where hi.sql_feature(+) = fh.sql_feature
  and ('&_path_mask' is null or regexp_like(fh.path,'&_path_mask'))
  and ('&_hint_mask' is null or regexp_like(hi.name,'&_hint_mask'))
  and ('&_min_ver'   is null or version is null or regexp_replace(regexp_replace(version,'(\d+)','0000\1'),'\d*(\d{2})','\1')>= regexp_replace(regexp_replace('&_min_ver','(\d+)','0000\1'),'\d*(\d{2})','\1'))
order by n, hint_class, hint_name, version
/
col path        clear;
col hint_class  clear;
col hint_name   clear;
col version     clear;
col ver_outline clear;

undef _path_mask _hint_mask _min_ver;
