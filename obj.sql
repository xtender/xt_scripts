@inc/input_vars_init;
select owner,object_name,object_id ,created,last_ddl_time
from dba_objects o 
where 
   (to_char(o.object_id) like '%&1%' or upper(object_name) like upper('%&1%'))
   and o.owner like nvl(upper('&2'),'%')
;
@inc/input_vars_undef;