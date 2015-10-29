@inc/input_vars_init.sql
set timing off
col owner       new_val _owner      format a20
col object_name new_val _object     format a30
col object_type new_val _type       format a15
col subobject_name                  format a30
col timestamp                       format a20

select distinct
  nvl(o2.owner          ,o.owner          ) owner
 ,nvl(o2.object_name    ,o.object_name    ) object_name
 ,nvl(o2.subobject_name ,o.subobject_name ) subobject_name
 ,nvl(o2.object_id      ,o.object_id      ) object_id
 ,nvl(o2.data_object_id ,o.data_object_id ) data_object_id
 ,nvl(o2.object_type    ,o.object_type    ) object_type
 ,nvl(o2.created        ,o.created        ) created
 ,nvl(o2.last_ddl_time  ,o.last_ddl_time  ) last_ddl_time
 ,nvl(o2.timestamp      ,o.timestamp      ) timestamp
 ,nvl(o2.status         ,o.status         ) status
 ,nvl(o2.temporary      ,o.temporary      ) temporary
 ,nvl(o2.generated      ,o.generated      ) generated
from dba_objects o
     left join dba_synonyms syn
          on  o.object_type    = 'SYNONYM'
          and syn.owner        = o.owner
          and syn.synonym_name = o.object_name
     left join dba_objects o2
          on  o.object_type    = 'SYNONYM'
          and o2.OWNER         = syn.table_owner
          and o2.OBJECT_NAME   = syn.table_name 
where o.object_name like upper(regexp_substr('&1','[^.]+$'))
  and o.owner  like case when instr('&1','.')>0 then upper(regexp_substr('&1','^[^.]*'))
                         when '&2' is not null then upper('&2')
                         else '%'
                    end
  and o.object_type   not in ('TABLE PARTITION','INDEX PARTITION')
  and (o.object_type like nvl(upper('&3'),'%'))
order by 
      decode(nvl(o2.owner          ,o.owner          )
               ,'SYS',1
               ,2
            )
     ,decode(nvl(o2.object_type    ,o.object_type    )
               ,'TABLE'  ,4
               ,'INDEX'  ,3
               ,'VIEW'   ,2
               ,'PACKAGE',1
               ,0
            )
/
prompt dbms_metadata.get_ddl for &_type  &_owner..&_object....
def _filename="&_TEMPDIR\get_ddl_&_CONNECT_IDENTIFIER..&_OWNER..&_OBJECT..sql"

set termout off timing off ver off feed off tab off head off lines 10000000 pagesize 0 newpage none
--exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',false);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
var c clob;
exec :c := ltrim(dbms_metadata.get_ddl('&_TYPE','&_OBJECT','&_OWNER'),' '||chr(10)||chr(13));
-------------- Spooling ------------------
spool &_filename
print c;
spool off
-------------- End Spooling ------------------
host &_filename
prompt DDL was spooled to &_filename
undef _OWNER;
undef _OBJECT;
undef _FILENAME;
@inc/input_vars_undef.sql