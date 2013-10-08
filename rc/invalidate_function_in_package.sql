prompt Invalidate result cache of the package function:
accept pkg_owner    prompt "Package owner:";
accept pkg_name     prompt "Package name :";
accept pkg_func     prompt "Function name:";

col name        format a80;
col cache_id    format a50;
col status      format a10;
select 
     d.* 
--    ,o.owner
--    ,o.object_name
    ,o.object_type
    ,rco.name
    ,rco.cache_id
    ,rco.status
    ,dbms_result_cache.Invalidate_Object(rco.id) invalidated
from 
     dba_objects o
    ,v$result_cache_dependency d
    ,v$result_cache_objects rco
where 
     o.object_id=d.object_no
 and rco.ID=d.result_id
 and o.owner='&pkg_owner'
 and o.object_name ='&pkg_name'
 and regexp_like(rco.name,'"'||o.owner||'"."'||o.object_name||'"::\d+.\."'||'&pkg_func".*')
/
prompt After invalidation:
select 
     d.* 
--    ,o.owner
--    ,o.object_name
    ,o.object_type
    ,rco.name
    ,rco.cache_id
    ,rco.status
from 
     dba_objects o
    ,v$result_cache_dependency d
    ,v$result_cache_objects rco
where 
     o.object_id=d.object_no
 and rco.ID=d.result_id
 and o.owner='&pkg_owner'
 and o.object_name ='&pkg_name'
 and regexp_like(rco.name,'"'||o.owner||'"."'||o.object_name||'"::\d+.\."'||'&pkg_func".*')
/
col name        clear;
col cache_id    clear;
col status      clear;