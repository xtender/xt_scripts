select id,type,status,name,namespace,creation_timestamp,scn from v$result_cache_objects where name like '%&1%'
/
