column sid      format 999999   ;
column serial#  format 999999   ;
column sql_id   format a13      new_val _sqlid;
column program  format a20      ;
column sql      format a80      ;
column event    format a40      ;
column ospid    format a9       ;
column obj_name format a40      ;
select
   ss.sid
  ,ss.serial#
  ,p.spid as ospid
  ,ss.program
  ,event
  ,sql_id
  ,(select substr(sql_text,1,60) from v$sql s where s.sql_id=ss.sql_id and rownum=1) sql
  ,ss.row_wait_obj#
  ,(select nvl(subobject_name,object_name) from dba_objects o where object_id=row_wait_obj#) obj_name
from gv$session ss
    ,gv$process p
where 
      ss.osuser  = sys_context('USERENV','OS_USER')
  and ss.paddr   = p.addr
  and ss.inst_id = p.inst_id
  and ss.status  = 'ACTIVE'
  and not (ss.SID = USERENV('SID') and ss.inst_id = USERENV('INSTANCE'))
  and not exists(select 1 
                  from gv$px_session ps 
                  where ps.qcinst_id = &DB_INST_ID 
                    and ps.qcsid     = &MY_SID 
                    and ps.inst_id   = ss.inst_id 
                    and ps.sid       = ss.sid
                )
order by ss.status;

column sid      clear;
column serial#  clear;
column program  clear;
column sql      clear;
column event    clear;
column ospid    clear;
column obj_name clear;

prompt Explain plan for sql_id='&_sqlid':

@plan &_sqlid