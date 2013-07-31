select
   dbms_metadata.get_ddl(o.object_type,object_name,o.owner) ddl_text
from dba_objects o
where 
      o.owner like upper('&1') 
  and o.object_name like upper('&2');