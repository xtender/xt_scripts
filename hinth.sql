--------------------------------------------------------------------------------
--
-- File name:   hinth.sql (Hint Hierarchy)
--
-- Purpose:     Display the areas / features in Oracle kernel that a hint affects
--              (displayed as a feature/module hierarchy)
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @hinth <hint_name>
--              @hinth MERGE
--          
-- Other:       Requires Oracle 11g+
--
--------------------------------------------------------------------------------

COL sqlfh_feature HEAD SQL_FEATURE FOR A55
COL hinth_path HEAD PATH FOR A150

PROMPT Display Hint feature hierarchy for hints like &1

WITH feature_hierarchy AS (
SELECT 
    f.sql_feature
  , SYS_CONNECT_BY_PATH(REPLACE(f.sql_feature, 'QKSFM_', ''), ' -> ') path
FROM 
    v$sql_feature f
  , v$sql_feature_hierarchy fh 
WHERE 
    f.sql_feature = fh.sql_feature 
CONNECT BY fh.parent_id = PRIOR f.sql_Feature 
START WITH fh.sql_feature = 'QKSFM_ALL'
)
SELECT
    hi.name as sqlfh_feature
  , REGEXP_REPLACE(fh.path, '^ -> ', '') as hinth_path
FROM
    v$sql_hint hi
  , feature_hierarchy fh
WHERE
    hi.sql_feature = fh.sql_feature
--    hi.sql_feature = REGEXP_REPLACE(fh.sql_feature, '_[[:digit:]]+$')
AND (UPPER(hi.name) LIKE UPPER('%&1%')
        or fh.path LIKE UPPER('%&1%')
    )
ORDER BY
    path
  --name
/