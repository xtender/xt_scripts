@inc/input_vars_init;
col OBJECT_NAME             format a50;
col TYPE                    format a12;
col REF_OWNER               format a30 heading REF_OWNER;
col REF_NAME                format a30 heading REF_NAME;
col REF_TYPE                format a12 heading REF_TYPE;
col REF_LINK_NAME           format a10 heading REF_LINK;
col DEPENDENCY_TYPE         format a10;
break on ref_type on ref_owner on ref_name on object_name;

prompt ===============================================================================;
prompt List of the objects depending on the object:
prompt ;

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

prompt ===============================================================================;
prompt List of the objects on which the object depends:
prompt ;

col name     for a30;
col ref_name for a45;
break on type on owner on name skip 1;

with
dd as (
  select/*+ materialize qb_name dd */
     *
  from (
       select 
            owner
           ,name
           ,type
           ,referenced_owner
           ,referenced_name
           ,referenced_type
           ,dependency_type
        from dba_dependencies
        where 1=1
       and referenced_link_name is null
       and not ( referenced_owner ='SYS' and referenced_name='STANDARD' ) 
       and referenced_type != 'NON-EXISTENT'
  )
  where rownum>0
)
,deps as (
   select--+ materialize qb_name(deps)
      rownum n
     ,v.*
   from (
         select
            connect_by_root type                      as type
           ,connect_by_root owner                     as owner
           ,connect_by_root name                      as name
           ,level                                     as dep_level
           ,sys_connect_by_path(owner||'.'||name,'>') as dep_path
           ,dd.referenced_owner                       as referenced_owner
           ,dd.referenced_name                        as referenced_name
           ,dd.referenced_type                        as referenced_type
           ,dd.dependency_type                        as dependency_type
         from  dd
         start with
                    dd.name              = upper('&1')
                and dd.owner like coalesce(upper('&2'),'%')
                and dd.type  like coalesce(upper('&3'),'%')
         connect by level<=3
                and prior dd.referenced_owner = dd.OWNER
                and prior dd.referenced_name  = dd.NAME
                and prior dd.REFERENCED_TYPE  = dd.TYPE
                and prior dd.referenced_owner != 'SYS'
                and not ( dd.referenced_owner ='SYS' and dd.referenced_name='STANDARD' )
         order siblings by dd.referenced_owner,dd.referenced_name
    ) v
)
,vdistinct as (
   select
     n
    ,type
    ,owner
    ,name
    ,dep_level
    ,dep_path
    ,referenced_owner
    ,referenced_name
    ,referenced_type
    ,dependency_type
   from (
      select deps.*
            ,row_number()over(partition by referenced_owner,referenced_name,referenced_type order by dep_level) rn
      from deps
      )
   where rn=1
)
select 
     type
    ,owner
    ,name
--    ,dep_level
--    ,dep_path
--    ,referenced_owner
--    ,referenced_name
--    ,referenced_type
    ,ltrim(rpad('  ',dep_level*2,'..')||dd.referenced_owner||'.'||dd.referenced_name) as ref_name
    ,dd.REFERENCED_TYPE                                                               as ref_type
    ,(select o.CREATED        from dba_objects o where o.OWNER = dd.OWNER and o.object_type = dd.type and o.object_name = dd.name) CREATED
    ,(select o.LAST_DDL_TIME  from dba_objects o where o.OWNER = dd.OWNER and o.object_type = dd.type and o.object_name = dd.name) LAST_DDL_TIME
    ,(select o.status         from dba_objects o where o.OWNER = dd.OWNER and o.object_type = dd.type and o.object_name = dd.name) obj_status
    ,dependency_type
from vdistinct dd
order by n
/

col OBJECT_NAME             clear;
col TYPE                    clear;
col REF_OWNER               clear;
col REF_NAME                clear;
col REF_TYPE                clear;
col REF_LINK_NAME           clear;
col DEPENDENCY_TYPE         clear;

clear break;
@inc/input_vars_undef;
