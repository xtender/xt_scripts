col OWNER           for a30;
col DIRECTORY_NAME  for a30;
col DIRECTORY_PATH  for a150;
select d.*
from dba_directories d
order by 1,2;
col OWNER           clear;
col DIRECTORY_NAME  clear;
col DIRECTORY_PATH  clear;

accept v_dump_dir  prompt 'Dump dir : ';
accept v_dump_name prompt 'Dump name: ';
prompt *** Enter version: COMPATIBLE (default), LATEST (dbversion), or value (11.0.0 or 12)
accept v_dump_ver  prompt 'Version  : ' default 'COMPATIBLE';

set serverout on;

declare
      l_datapump_handle    NUMBER;  -- Data Pump job handle
      l_datapump_dir       VARCHAR2(20) := '&v_dump_dir';  -- Data Pump Directory
      l_status             varchar2(200); -- Data Pump Status
  BEGIN
      l_datapump_handle := dbms_datapump.open(operation => 'EXPORT',  -- operation = EXPORT, IMPORT, SQL_FILE
                                              job_mode  => 'FULL',      -- job_mode = FULL, SCHEMA, TABLE, TABLESPACE, TRANSPORTABLE
                                              job_name  => '&v_dump_name EXPORT JOB',  -- job_name = NULL (default) or: job name (max 30 chars)
                                              version   => '&v_dump_ver'); -- version = COMPATIBLE (default), LATEST (dbversion), a value (11.0.0 or 12)

          dbms_datapump.add_file(handle    => l_datapump_handle,
                             filename  => 'exp_&v_dump_name_%U.dmp',
                             directory => l_datapump_dir);

      dbms_datapump.add_file(handle    => l_datapump_handle,
                             filename  => 'exp_&v_dump_name_%U.log' ,
                             directory => l_datapump_dir ,
                             filetype  => DBMS_DATAPUMP.ku$_file_type_log_file);

      dbms_datapump.set_parameter(l_datapump_handle,'CLIENT_COMMAND','Full Consistent Data Pump Export of &v_dump_name with PARALLEL 8');

          dbms_datapump.set_parameter(l_datapump_handle,'FLASHBACK_TIME','SYSTIMESTAMP');

      dbms_datapump.set_parallel(l_datapump_handle,8);

      dbms_datapump.start_job(handle => l_datapump_handle);

      dbms_datapump.wait_for_job(handle => l_datapump_handle,
                                 job_state => l_status );

      dbms_output.put_line( l_status );

      end;
/
