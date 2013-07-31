@inc/input_vars_init;
col object_type     format a20;
col owner           format a15;
col object_name     format a30;
col procedure_name  format a30;

select OBJECT_ID,SUBPROGRAM_ID,object_type,owner,object_name,procedure_name
from dba_procedures p 
where 
      p.OBJECT_ID=regexp_substr('&1','^[^,]+')
  and p.SUBPROGRAM_ID=nvl('&2',1);

@inc/input_vars_undef;
col object_type     clear;
col owner           clear;
col object_name     clear;
col procedure_name  clear;