select dbms_metadata.get_ddl(o.OBJECT_TYPE,o.OBJECT_NAME,o.owner)
from dba_objects o
where o.OBJECT_NAME like '&obj_mask'
/
