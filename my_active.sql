column sid      format 999999   ;
column serial#  format 999999   ;
column sql_id   format a13      ;
column program  format a20      ;
column sql      format a80      ;
column event    format a40      ;
column action   format a30      ;
column ospid    format a9       ;
column obj_name format a40      ;
select
   ss.inst_id
  ,ss.sid
  ,ss.serial#
  ,p.spid as ospid
  ,ss.program
  ,event
  ,action
  ,sql_id
  ,(select substr(sql_text,1,60) from v$sql s where s.sql_id=ss.sql_id and rownum=1) sql
  ,ss.row_wait_obj#
  ,(select nvl(subobject_name,object_name) from dba_objects o where object_id=row_wait_obj#) obj_name
from gv$session ss
    ,gv$process p
where 
      ss.osuser  = sys_context('USERENV','OS_USER')
  and ss.paddr   = p.addr
  and ss.status  = 'ACTIVE'
  and ss.SID    != USERENV('SID')
  and ss.inst_id = p.inst_id
order by ss.status;

column sid      clear;
column serial#  clear;
column program  clear;
column sql      clear;
column event    clear;
column action   clear;
column ospid    clear;
column obj_name clear;