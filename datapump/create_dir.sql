col dir_name for a30;
col dir_path for a150;

select directory_name as dir_name
      ,directory_path as dir_path
from dba_directories 
where owner='SYS'
/
accept _dir_name prompt "Enter new directory name[empty to cancel]: ";
accept _dir_path prompt "Enter new directory path[empty to cancel]: ";
set serverout on;
prompt ************************************************;

declare
   procedure p_os_exec(command varchar2, arg varchar2) is
      l_job_name  varchar2(100):='OS_JOB';
      
      l_dir_name  varchar2(200);
      
      p_argument1 varchar2(100);
      p_argument2 varchar2(100);
   begin

      dbms_scheduler.create_job(
         job_name => l_job_name
        ,job_type => 'EXECUTABLE'
        ,job_action => '/bin/bash'
        ,number_of_arguments => 2
        ,start_date => NULL
        ,repeat_interval => NULL
        ,end_date => NULL
        ,enabled => false
        ,auto_drop => TRUE
      ); 
      dbms_scheduler.set_job_argument_value(l_job_name, 1, command);
      dbms_scheduler.set_job_argument_value(l_job_name, 2, arg);
      dbms_scheduler.enable(l_job_name);
   end;
begin
   if '&_dir_name' is not null then
      p_os_exec('mkdir', '&_dir_path');
      execute immediate q'[CREATE DIRECTORY &_dir_name AS '&_dir_path'  ]';
      dbms_output.put_line(q'[created directory &_dir_name AS '&_dir_path'  ]');
   end if;
end;
/
prompt ************************************************;

declare
   lv_pattern varchar2(1024);
   lv_ns      varchar2(1024);
begin
   select directory_path
   into lv_pattern
   from dba_directories
   where directory_name = '&_dir_name';
   
   sys.dbms_backup_restore.searchfiles(lv_pattern, lv_ns);
end;
/
SELECT indx, FNAME_KRBMSFT AS file_name FROM X$KRBMSFT
