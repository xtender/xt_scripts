col name        format a30;
col sql_feature format a35;
col class       format a30;
col version     format a20;
select name,sql_feature,class,version from v$sql_hint where name like upper('%&1%') or sql_feature like upper('%&1%') or class like upper('%&1%');
col name        clear;
col sql_feature clear;
col class       clear;
col version     clear;