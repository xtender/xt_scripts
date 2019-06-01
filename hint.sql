col name        format a30;
col sql_feature format a30;
col class       format a27;
col version     format a8;
col inverse     format a30;
col target_level for a40;
select name,sql_feature,class,version,inverse 
      ,(select listagg(column_value,',') within group (order by 1) 
        from table(ku$_vcnt(
         decode(bitand(target_level,1),0,'','Statement') 
        ,decode(bitand(target_level,2),0,'','Query_block')
        ,decode(bitand(target_level,4),0,'','Object')
        ,decode(bitand(target_level,8),0,'','Join')
        )))
      as target_level
from v$sql_hint 
where 
      name          like upper('%&1%') 
   or sql_feature   like upper('%&1%') 
   or class         like upper('%&1%')
   or version       like '&1%';
col name        clear;
col sql_feature clear;
col class       clear;
col version     clear;
col inverse     clear;
col target_level clear;