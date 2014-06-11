@inc/input_vars_init;
col OBJECT_NAME             format a50;
col TYPE                    format a12;
col REF_OWNER               format a30 heading REF_OWNER;
col REF_NAME                format a30 heading REF_NAME;
col REF_TYPE                format a12 heading REF_TYPE;
col REF_LINK_NAME           format a10 heading REF_LINK;
col DEPENDENCY_TYPE         format a10;
break on ref_type on ref_owner on ref_name on object_name;

prompt Dependencies list:

select
   connect_by_root referenced_type   as ref_type
  ,connect_by_root referenced_owner  as ref_owner
  ,connect_by_root referenced_name   as ref_name
  ,rpad('  ',level*2,'..')||dd.OWNER||'.'||dd.NAME as object_name
  ,dd.type
  ,(select o.CREATED        from dba_objects o where o.OWNER = dd.OWNER and o.object_type = dd.type and o.object_name = dd.name) CREATED
  ,(select o.LAST_DDL_TIME  from dba_objects o where o.OWNER = dd.OWNER and o.object_type = dd.type and o.object_name = dd.name) LAST_DDL_TIME
  ,(select o.status         from dba_objects o where o.OWNER = dd.OWNER and o.object_type = dd.type and o.object_name = dd.name) obj_status
from dba_dependencies dd
start with
           dd.referenced_owner like nvl(upper('&2'),'%')
       and dd.referenced_name         = upper('&1')
       and dd.referenced_link_name is null
connect by level<=3
       and dd.referenced_owner = prior dd.OWNER
       and dd.referenced_name  = prior dd.NAME
       and dd.REFERENCED_TYPE  = prior dd.TYPE
       and dd.REFERENCED_LINK_NAME is null
;

col OBJECT_NAME             clear;
col TYPE                    clear;
col REF_OWNER               clear;
col REF_NAME                clear;
col REF_TYPE                clear;
col REF_LINK_NAME           clear;
col DEPENDENCY_TYPE         clear;

clear break;
@inc/input_vars_undef;
