accept _path_mask prompt "Path mask[.*]: " default '.*';
accept _min_ver   prompt "Min version: "   default '';

col path            for a90;
col description     for a64;
col opt_feat_enable for a8;

with feature_hierarchy as (
   select--+ no_merge
      rownum n
     ,f.sql_feature
     ,substr(SYS_CONNECT_BY_PATH(REPLACE(f.sql_feature, 'QKSFM_'), ' -> '),5) path
   from 
       v$sql_feature f
     , v$sql_feature_hierarchy fh 
   where 
       f.sql_feature = fh.sql_feature 
   connect by fh.parent_id = prior f.sql_feature 
   start with fh.sql_feature = 'QKSFM_ALL'
)
select 
   fh.path
  ,c.bugno
  ,c.description
  ,c.optimizer_feature_enable as opt_feat_enable
  ,c.event
  ,c.is_default
from 
    feature_hierarchy fh
   ,v$system_fix_control c
where 
      fh.sql_feature = regexp_replace(c.sql_feature,'_\d+$')
  and ('&_path_mask' is null or regexp_like(fh.path,'&_path_mask','i'))
  and ('&_min_ver'   is null 
       or c.optimizer_feature_enable is null 
       or regexp_replace(regexp_replace(c.optimizer_feature_enable,'(\d+)','0000\1'),'\d*(\d{2})','\1')
          >= 
          regexp_replace(regexp_replace('&_min_ver'               ,'(\d+)','0000\1'),'\d*(\d{2})','\1')
      )
/
col path            clear;
col description     clear;
col opt_feat_enable clear;

undef _path_mask _hint_mask _min_ver;
