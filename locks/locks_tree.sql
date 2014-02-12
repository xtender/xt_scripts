PROMPT &_C_RED.&_CB_WHITE.********** Locks tree ***************&_C_RESET
@inc/input_vars_init;
-----------------------------------------------------------------------
-- input params init:
set termout off;
col if_pl       new_val _if_pl   noprint;
col if_data     new_val _if_data noprint;
select
   case when lower('&1 &2 &3 &4 &5') like '%+pl%' then ''
        when lower('&1 &2 &3 &4 &5') like '%-pl%' then '--'
        -- default:
        else '--'
   end if_pl
 , case when lower('&1 &2 &3 &4 &5') like '%+data%' then ''
        when lower('&1 &2 &3 &4 &5') like '%-data%' then '--'
        -- default:
        else '--'
   end if_data
from dual;
set termout on;
-- end input params init;
-----------------------------------------------------------------------
col lev             format 999
col sid             format a20
col serial#         format 99999999
col b_obj           format a30
col srowid          format a18
col sqltext         format a73
col sqlsubstring    format a73
col usern           format a12
col osuser          format a12
col waited          format a15
col event           format a30
col ple             format a35 word
col plo             format a35 word
-----------------------------------------------------------------------
with 
 v#session as (
   select--+ materialize no_merge use_hash(ss.w ss.e ss.s)
          ss.sid
         ,ss.serial#
         ,ss.inst_id
         ,ss.username
         ,ss.terminal
         ,ss.osuser
         ,ss.sql_id
         ,ss.sql_child_number
         ,ss.plsql_entry_object_id
         ,ss.plsql_entry_subprogram_id
         ,ss.plsql_object_id
         ,ss.plsql_subprogram_id
         ,ss.ROW_WAIT_OBJ#
         ,ss.ROW_WAIT_FILE#
         ,ss.ROW_WAIT_BLOCK#
         ,ss.ROW_WAIT_ROW#
         ,ss.wait_class
         ,ss.event
         ,ss.wait_time
         ,ss.seconds_in_wait
         ,ss.blocking_session
         ,ss.blocking_instance
         ,ss.blocking_session_status
         ,rownum rn
   from gv$session ss
   where 1=1
 )
,lock_tree as (
   select--+ materialize
        distinct
          s.BLOCKING_SESSION
         ,s.sid
         ,s.serial#
         ,s.username
   --      ,terminal
         ,s.osuser
         ,(select o.object_name from dba_objects o where o.OBJECT_ID=s.ROW_WAIT_OBJ#) b_obj
         ,s.ROW_WAIT_OBJ#,s.ROW_WAIT_FILE#,s.ROW_WAIT_BLOCK#,s.ROW_WAIT_ROW#
         ,s.wait_class
         ,s.EVENT
         ,s.WAIT_TIME+s.SECONDS_IN_WAIT waittime
         ,s.sql_id
         ,s.sql_child_number
         ,s.plsql_entry_object_id
         ,s.plsql_entry_subprogram_id
         ,s.plsql_object_id
         ,s.plsql_subprogram_id
         ,max(length(sid))over() max_len
         ,CONNECT_BY_ISLEAF leaf
   from   v#session s
   start with s.blocking_session_status = 'VALID'
   connect by nocycle prior s.BLOCKING_SESSION = s.sid and prior s.BLOCKING_INSTANCE = s.INST_ID
)
select --+ no_merge(lt)
             level lev
            --,sys_connect_by_path(sid,'/') sid
            ,decode(level,1,to_char(sid),lpad('.',max_len*(level-1),'.')||lt.sid) sid
            ,lt.serial#         serial#
            ,lt.b_obj            b_obj
            ,decode(ROW_WAIT_ROW#,null,null,0,null,dbms_rowid.rowid_create(1,ROW_WAIT_OBJ#,ROW_WAIT_FILE#,ROW_WAIT_BLOCK#,ROW_WAIT_ROW#)) srowid
            ,lt.BLOCKING_SESSION b_sid
            ,lt.username         usern
            ,lt.osuser           osuser
            ,lt.wait_class       waited
            ,lt.EVENT            event
            ,lt.waittime         waittime
            ,lt.sql_id           sql_id
&_if_pl     ,(select p.OBJECT_TYPE||' '|| p.owner||'.'||p.object_name||'.'||p.procedure_name 
&_if_pl       from dba_procedures p 
&_if_pl       where p.object_id     = lt.plsql_entry_object_id 
&_if_pl         and p.subprogram_id = lt.plsql_entry_subprogram_id
&_if_pl      ) ple
&_if_pl     ,(select p.OBJECT_TYPE||' '|| p.owner||'.'||p.object_name||'.'||p.procedure_name 
&_if_pl       from dba_procedures p 
&_if_pl       where p.object_id     = lt.plsql_object_id
&_if_pl         and p.subprogram_id = lt.plsql_subprogram_id
&_if_pl      ) plo

            ,(select substr(v$sql.sql_text,1,70)||'...' from v$sql where v$sql.sql_id=lt.sql_id and rownum=1) sqlsubstring
          --,(select sql_text from v$sql st where st.SQL_ID=lt.sql_id and st.child_number=sql_child_number) sqltext
&_if_data
&_if_data   ,decode(ROW_WAIT_ROW#
&_if_data           ,null,null
&_if_data           ,0,null
&_if_data           ,dbms_xmlgen.getxmltype( ' select * '
&_if_data                                  ||' from '
&_if_data                                           ||( select object_name 
&_if_data                                               from dba_objects o
&_if_data                                               where o.object_id=ROW_WAIT_OBJ#)
&_if_data                                  ||' where'
&_if_data                                  ||' rowid='''
&_if_data                                           ||dbms_rowid.rowid_create(1,ROW_WAIT_OBJ#,ROW_WAIT_FILE#,ROW_WAIT_BLOCK#,ROW_WAIT_ROW#)
&_if_data                                           ||''''
&_if_data           )
&_if_data        ) as obj_data

from lock_tree lt
start with leaf=1
connect by nocycle prior lt.sid = lt.BLOCKING_SESSION
order siblings by lt.sid
/
col sid     clear;
col serial# clear;
col b_obj   clear;
col sqltext clear;
col usern   clear;
col osuser  clear;
col waited  clear;
col event   clear;
col srowid  clear;
col ple     clear;
col plo     clear;
@inc/input_vars_undef;
