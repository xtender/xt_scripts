col object_name format a30
select object_type,owner,object_name from dba_objects o where o.object_name like '&obj_mask'
/
clear col
