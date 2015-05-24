set feed off;
whenever sqlerror exit;

prompt ~~~~~~~~~~
prompt  AWR LOAD 
prompt ~~~~~~~~~~
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt ~  This script will load the AWR data from a dump file. The   ~
prompt ~  script will prompt users for the following information:    ~
prompt ~     (1) name of directory object                            ~
prompt ~     (2) name of dump file                                   ~
prompt ~     (3) staging schema name to load AWR data into           ~
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--
-- Ask User for Directory Name
--

prompt
prompt Specify the Directory Name
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~

col owner    for a30;
col dir_name for a30;
col dir_path for a120;
select
    owner
  , directory_name as dir_name
  , directory_path as dir_path
FROM dba_directories
/
variable dmpdir  varchar2(30);
variable dmppath varchar2(30);
variable dmpfile varchar2(30);

accept _dmpdir prompt "Enter directory name: ";

declare
   lv_pattern varchar2(1024);
   lv_ns      varchar2(1024);
begin
   :dmpdir  := q'[&_dmpdir]';
   
   select directory_path
   into lv_pattern
   from dba_directories
   where directory_name = '&_dmpdir';
   
   sys.dbms_backup_restore.searchfiles(lv_pattern, lv_ns);
end;
/
SELECT indx, FNAME_KRBMSFT AS file_name
FROM X$KRBMSFT;

prompt;
accept _dmpfile prompt "Please specify the prefix of the dump file (.dmp) to load(without path): ";

begin
   :dmpfile := q'[&_dmpfile]';
end;
/

---------------------------------------------------------
-- Original Stage schema creation:

set termout off;
column dflt_schema new_value dflt_schema noprint;
select 'AWR_STAGE'  dflt_schema from dual;
set termout on;

prompt
prompt Staging Schema to Load AWR Snapshot Data
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt The next step is to create the staging schema 
prompt where the AWR snapshot data will be loaded.
prompt After loading the data into the staging schema,
prompt the data will be transferred into the AWR tables
prompt in the SYS schema.
prompt 
prompt
prompt The default staging schema name is &dflt_schema..
prompt To use this name, press <return> to continue, otherwise enter
prompt an alternative.
prompt  

set heading off;
column schema_name new_value schema_name noprint;
column schema_password new_value schema_password noprint;
select 'Using the staging schema name: ' || nvl('&&schema_name','&dflt_schema')
      , nvl('&&schema_name','&dflt_schema') schema_name
      , substr(nvl('&&schema_name','&dflt_schema'),1,2) || '$999$' 
        || substr(rawtohex(sys_guid()),11,10) || '$_#zzz$' schema_password
  from sys.dual;

variable schname varchar2(30);
variable schcount number;

/* check if schema already exists */
declare
  cursor schemas (schname varchar2) is
    select count(*) schcount
      from dba_users 
      where username = schname
      order by username;

begin
  :schname := '&schema_name';

   /* select the directory path into a variable */
   open schemas(:schname);

   fetch schemas into :schcount;

   if (:schcount > 0) then
     RAISE_APPLICATION_ERROR(-20104, 
                             'schema name ''' || :schname || 
                              ''' already exists', TRUE);
   end if;
   
   close schemas;
end;
/

prompt
prompt Choose the Default tablespace for the &schema_name user
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Choose the &schema_name users`s default tablespace.  This is the 
prompt tablespace in which the AWR data will be staged.

set heading on
column db_default format a18 heading 'DEFAULT TABLESPACE'
select tablespace_name, contents
     , decode(tablespace_name,'SYSAUX','*') db_default
  from sys.dba_tablespaces 
 where tablespace_name <> 'SYSTEM'
   and contents = 'PERMANENT'
   and status = 'ONLINE'
 order by tablespace_name;
set heading off

prompt
prompt Pressing <return> will result in the recommended default
prompt tablespace (identified by *) being used.
prompt

col default_tablespace new_value default_tablespace noprint
select 'Using tablespace '||
       upper(nvl('&&default_tablespace','SYSAUX'))||
       ' as the default tablespace for the &&schema_name.'
     , nvl('&default_tablespace','SYSAUX') default_tablespace
  from sys.dual;


begin
  if upper('&&default_tablespace') = 'SYSTEM' then
    raise_application_error(-20105, 'Load failed - SYSTEM tablespace ' || 
                                    'specified for DEFAULT tablespace');
  end if;
end;
/

prompt
prompt
prompt Choose the Temporary tablespace for the &&schema_name user
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt Choose the &schema_name user`s temporary tablespace.

set heading on
column db_default format a23 heading 'DEFAULT TEMP TABLESPACE'
select t.tablespace_name, t.contents
     , decode(dp.property_name,'DEFAULT_TEMP_TABLESPACE','*') db_default
  from sys.dba_tablespaces t
     , sys.database_properties dp
 where t.contents           = 'TEMPORARY'
   and t.status             = 'ONLINE'
   and dp.property_name(+)  = 'DEFAULT_TEMP_TABLESPACE'
   and dp.property_value(+) = t.tablespace_name
 order by tablespace_name;

set heading off

prompt
prompt Pressing <return> will result in the database`s default temporary 
prompt tablespace (identified by *) being used.
prompt

col temporary_tablespace new_value temporary_tablespace noprint
select 'Using tablespace '||
       nvl('&&temporary_tablespace',property_value)||
       ' as the temporary tablespace for &&schema_name.'
     , nvl('&&temporary_tablespace',property_value) temporary_tablespace
  from database_properties
 where property_name='DEFAULT_TEMP_TABLESPACE';

begin
  if upper('&&temporary_tablespace') = 'SYSTEM' then
    raise_application_error(-20106, 'Load failed - SYSTEM tablespace ' || 
                                    'specified for TEMPORARY tablespace');
  end if;
end;
/

set heading off

prompt
prompt
prompt ... Creating &&schema_name user

create user &&schema_name
  identified by &&schema_password
  default tablespace &&default_tablespace
  temporary tablespace &&temporary_tablespace;

alter user &&schema_name quota unlimited on &&default_tablespace;

prompt

set termout on;
---------------------------------------------------------------------------
whenever sqlerror continue;
set heading off;
set linesize 110 pagesize 50000;
set echo off;
set feedback off;
set termout on;

begin
  /* call PL/SQL routine to load the data into the staging schema */
  dbms_swrf_internal.awr_load(schname  => :schname,
                              dmpfile  => :dmpfile,
                              dmpdir   => :dmpdir);
end;
/
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt AWR dump was succesfully loaded into stage schema;
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pause * Press Enter to continue (next step = move_to_awr)...

-- Check DBID:
---------------------------------------------------------------------------
set heading on;
select distinct dbid, version,db_name,instance_name,host_name from dba_hist_database_instance;
accept _dbid prompt "Enter AWR dbid if you want to change it before load: " default 0;
---------------------------------------------------------------------------

begin
  /* call PL/SQL routine to move the data into AWR */
  if &_dbid = 0 then
     dbms_swrf_internal.move_to_awr(schname => :schname);
  else 
     dbms_swrf_internal.move_to_awr(schname => :schname,
                                    new_dbid => &_dbid);
  end if;
  dbms_swrf_internal.clear_awr_dbid;
end;
/

prompt ... Dropping &&schema_name user

drop user &&schema_name cascade;

prompt
prompt End of AWR Load
set heading on lines 1500 feed on;
