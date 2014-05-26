set termout         off 
set echo            off
set timing          off
set tab             off
set ver             off
set pagesize        999
set lin             1500
set long            10000000
set longchunksize   10000000
set sqlblan         on
set trim            on
set trimspool       on
set editfile        "afiedt.sql"

-- windows: @inc/on_login_win
-- DEFINE _EDITOR  ="c:\Program Files\SciTE\SciTE.exe"
-- DEFINE _TEMPDIR ="c:/temp/sqlplus-tmp/"
-- DEFINE _SPOOLS  ="c:/temp/spools/"
-- DEFINE _START   ="start"
-- *nix: @inc/on_login_nix
-- DEFINE _EDITOR  ="/usr/bin/mcedit"
-- DEFINE _TEMPDIR ="/tmp/sqlplus/tmp/"
-- DEFINE _SPOOLS  ="/tmp/sqlplus/spools/"
-- DEFINE _START   ="open"

------------------------------------------------
--  Set default format for usual columns
col owner       format a20
col object_name format a30

------------------------------------------------
-- Load information about version and session

@inc/session_info
@inc/version_info
@inc/colors

alter session set nls_numeric_characters  =q'[.`]';
alter session set nls_date_format         ='yyyy-mm-dd hh24:mi:ss';
alter session set nls_time_format         ='hh24:mi:ssxff';
alter session set nls_time_tz_format      ='hh24:mi:ssxff TZR';
alter session set nls_timestamp_format    ='yyyy-mm-dd hh24:mi:ssxff';
alter session set nls_timestamp_tz_format ='yyyy-mm-dd hh24:mi:ssxff TZR';
set sqlprompt "SQL> "
def x=inc/comment_on
col x new_value x noprint
select 'inc/null' x from dual;
------------------------------------------------
prompt Show connect info and set sqlprompt
@&x

set termout on

@inc/title "&db_name / &my_user / &db_host_name   SID=&my_sid    SERIAL#=&my_serial     SPID=&my_spid     IS_DBA=&my_is_dba / INST_ID = &DB_INST_ID / DB_VERSION = &DB_VERSION"

-- set sqlprompt "[ _USER'@'_CONNECT_IDENTIFIER _PRIVILEGE] >> "
-- set sqlprompt "[ &my_user@&db_name ] >> "


PROMPT ======================================================================
PROMPT =======  Connected to  &my_user@&db_name(&db_host_name)  
PROMPT =======  SID           &my_sid                          
PROMPT =======  SERIAL#       &my_serial                       
PROMPT =======  SPID          &my_spid                         
REM prompt =======  DB_ID         &DB_ID 
REM prompt =======  DB_NAME       &DB_NAME 
REM prompt =======  DB_INST_ID    &DB_INST_ID 
REM prompt =======  DB_HOST_NAME  &DB_HOST_NAME
prompt =======  DB_VERSION    &DB_VERSION
PROMPT ======================================================================

/* end_if */

------------------------------------------------
--@inc/params_undef
--set timing on
--set serveroutput on

------------------------------------------------
col x clear;
set termout on
