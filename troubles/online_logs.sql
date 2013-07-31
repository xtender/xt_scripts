select 
     o.object_id "OID online log"
    ,o.owner
    ,o.object_name 
    ,o2.owner
    ,o2.object_name
    ,o2.object_type
    ,o2.created
from dba_objects o 
    ,dba_objects o2
where 
     o.object_name like 'SYS_JOURNAL%'
 and o2.object_id  = to_number(substr(o.object_name,13));