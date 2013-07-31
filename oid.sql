-- Script by Tanel Poder (http://www.tanelpoder.com)
--
-- Look up object info by object id 

col o_owner             heading owner       for a25
col o_object_name       heading object_name for a30
col o_object_type       heading object_type for a18
col o_subobject_name    heading subobject   for a30
col o_status            heading status      for a9

select 
     owner          as o_owner
    ,object_name    as o_object_name
    ,subobject_name as o_subobject_name
    ,object_type    as o_object_type
    ,created
    ,last_ddl_time
    ,status         as o_status
    ,data_object_id
from 
    dba_objects 
where 
    object_id in (&1)
order by 
    o_object_name,
    o_owner,
    o_object_type
/
