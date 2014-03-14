@inc/input_vars_init;

prompt &_CB_RED &_C_WHITE * Mass kill session &_C_RESET;
prompt &_C_REVERSE *** Some columns from v$session:&_C_RESET
prompt *                   USERNAME, STATUS, OSUSER, MACHINE, TERMINAL, PROGRAM, SQL_ID, MODULE, ACTION, CLIENT_INFO,
prompt *                   LOGON_TIME, PQ_STATUS, CLIENT_IDENTIFIER, EVENT, WAIT_CLASS, WAIT_TIME, SECONDS_IN_WAIT,
prompt *                   STATE, SERVICE_NAME, SQL_TRACE.
prompt *

accept _where prompt 'Enter where clause from v$session: ';
set serverout on feed off;
spool &_SPOOLS/p_killall.sql;
declare
   procedure p_kill( p_sid      int
                    ,p_serial   int
                    ,p_osuser   varchar2
                    ,p_username varchar2 
                    ,p_action   varchar2
                    ,p_event    varchar2
                   )
   is
   begin
      dbms_output.put_line(
         utl_lms.format_message(
                                q'[alter system kill session '%s,%s' immediate /* osuser=%s, username=%s, action=%s, event=%s */;]'
                               ,to_char(p_sid)
                               ,to_char(p_serial)
                               ,p_osuser
                               ,p_username
                               ,p_action
                               ,p_event
                                ));
   end p_kill;
begin
   for r in (select vs.sid,vs.serial#,vs.osuser,vs.username,vs.action,vs.event
             from v$session vs
             where vs.sid!=sys_context('userenv','sid')
               and vs.type!='BACKGROUND'
               and &_where
            )
   loop
      p_kill(r.sid,r.serial#,r.osuser,r.username,r.action,r.event);
   end loop;
end;
/
spool off;
set serverout off;
accept _v prompt 'Are you sure? [N/y]: ';
set termout off;
col exec_ new_value _exec;
select decode('&_v','y','&_SPOOLS/p_killall.sql','inc/null') "exec_" from dual;
set termout on echo on feed on;
@&_exec;
set echo off feed off;
col exec_ clear;
undef _where _v _exec;
@inc/input_vars_undef;
