prompt ************************************************
prompt *** Extract AWR data to DATA_PUMP_DIRECTORY 
prompt *** 
prompt *** You can create directoty for AWR data.
prompt *** 
prompt *** Existing directories:
prompt ;

col dir_name for a30;
col dir_path for a150;

select directory_name as dir_name
      ,directory_path as dir_path
from dba_directories 
where owner='SYS'
/
accept _dir_name prompt "Enter new directory name[empty to cancel]: ";
accept _dir_path prompt "Enter new directory path[empty to cancel]: ";
prompt Choose SHELL path:
prompt * Default on WINDOWS: c:\WINDOWS\system32\cmd.exe /c
prompt * Default on *NIX   : /bin/bash [default]
accept _shell    prompt "SHELL path[/bin/bash]: " default '/bin/bash';
set serverout on;

declare
   procedure p_os_exec(command varchar2, arg varchar2) is
      l_job_name  varchar2(100):='OS_JOB';
      
      l_dir_name  varchar2(200);
      
      p_argument1 varchar2(100);
      p_argument2 varchar2(100);
   begin

      dbms_scheduler.create_job(
         job_name            => l_job_name
        ,job_type            => 'EXECUTABLE'
        ,job_action          => q'[&_shell]'
        ,number_of_arguments => 2
        ,start_date          => NULL
        ,repeat_interval     => NULL
        ,end_date            => NULL
        ,enabled             => false
        ,auto_drop           => TRUE
      ); 
      dbms_scheduler.set_job_argument_value(l_job_name, 1, command);
      dbms_scheduler.set_job_argument_value(l_job_name, 2, arg);
      dbms_scheduler.enable(l_job_name);
   end;
begin
   if '&_dir_name' is not null then
      p_os_exec('mkdir', q'[&_dir_path]');
      execute immediate q'[CREATE DIRECTORY &_dir_name AS '&_dir_path'  ]';
      dbms_output.put_line(q'[created directory &_dir_name AS '&_dir_path'  ]');
   end if;
end;
/
prompt ************************************************

@inc/input_vars_init;
@?/rdbms/admin/awrextr;
@inc/input_vars_undef;

prompt ************************************************
prompt * use "select bfilename('AWR_DATA','file.DMP') from dual"
prompt * to get file
prompt ************************************************
