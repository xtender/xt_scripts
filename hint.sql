select name,sql_feature,class,version from v$sql_hint where name like upper('%&1%')
/
