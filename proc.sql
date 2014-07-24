prompt ===========================================================
prompt * Info from dba_procedures
prompt * Usage: @proc OBJECT_ID SUBPROGRAM_ID
prompt *    or: @proc object_name [procedure_name [owner]]
prompt ===========================================================

@inc/input_vars_init;

@inc/main;

col obj_id          format 99999999;
col sub_id          format 999999;
col owner           format a15;
col object_type     format a20;
col object_name     format a30;
col procedure_name  format a30;
col overload        format a10;
col impltypeowner   format a10;
col impltypename    format a10;
col authid          format a10;
break on obj_id on object_type on owner on object_name skip 1;
select
       object_id        as obj_id
      ,object_type
      ,owner
      ,object_name
      ,subprogram_id    as sub_id
      ,procedure_name
      ,authid
      ,overload
      ,parallel
      ,interface
      ,deterministic
      ,aggregate
      ,pipelined
      ,impltypeowner
      ,impltypename
from (
      select * from dba_procedures p 
      where regexp_like('&1','^\d+$')
        and p.object_id     = to_number(regexp_substr('&1','\d+'))
        and p.subprogram_id = nvl(to_number(regexp_substr('&2','\d+')),1)
   union all
      select * from dba_procedures p 
      where '&3' is not null
        and p.owner = upper('&3')
        and p.object_name    = upper('&1')
        and (
             (trim(both '%' from '&2') is null and p.procedure_name is null)
             or 
             (p.procedure_name like nvl(upper('&2'),'%'))
            )
   union all
      select * from dba_procedures p 
      where '&3' is null
        and p.object_name    = upper('&1')
        and (
             (trim(both '%' from '&2') is null and p.procedure_name is null)
             or 
             (p.procedure_name like nvl(upper('&2'),'%'))
            )
      )
order by owner,object_name,object_id,subprogram_id;

col obj_id          clear;
col sub_id          clear;
col object_type     clear;
col owner           clear;
col object_name     clear;
col procedure_name  clear;
col overload        clear;
clear break;
/* end main */
@inc/input_vars_undef;
