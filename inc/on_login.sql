set termout         off 
set echo            off
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

------------------------------------------------
--  Save input params
set timing off
COLUMN 1  NEW_VALUE 1
COLUMN 2  NEW_VALUE 2
COLUMN 3  NEW_VALUE 3
COLUMN 4  NEW_VALUE 4
COLUMN 5  NEW_VALUE 5
COLUMN 6  NEW_VALUE 6
COLUMN 7  NEW_VALUE 7
COLUMN 8  NEW_VALUE 8
COLUMN 9  NEW_VALUE 9
COLUMN 10 NEW_VALUE 10
COLUMN 11 NEW_VALUE 11
COLUMN 12 NEW_VALUE 12
COLUMN 13 NEW_VALUE 13
COLUMN 14 NEW_VALUE 14
COLUMN 15 NEW_VALUE 15
COLUMN 16 NEW_VALUE 16
COLUMN 17 NEW_VALUE 17
COLUMN 18 NEW_VALUE 18
COLUMN 19 NEW_VALUE 19
COLUMN 20 NEW_VALUE 20
SELECT ''  "1", ''  "2", ''  "3", ''  "4", ''  "5", ''  "6", ''  "7", ''  "8", ''  "9", '' "10"  
      ,'' "11", '' "12", '' "13", '' "14", '' "15", '' "16", '' "17", '' "18", '' "19", '' "20"
FROM dual WHERE 1 = 0;
def INPUT1 ="&1"
def INPUT2 ="&2"
def INPUT3 ="&3"
def INPUT4 ="&4"
def INPUT5 ="&5"
def INPUT6 ="&6"
def INPUT7 ="&7"
def INPUT8 ="&8"
def INPUT9 ="&9"
def INPUT10="&10"
def INPUT11="&11"
def INPUT12="&12"
def INPUT13="&13"
def INPUT14="&14"
def INPUT15="&15"
def INPUT16="&16"
def INPUT17="&17"
def INPUT18="&18"
def INPUT19="&19"
def INPUT20="&20"

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
alter session set nls_date_format         ='yyyy-mm-dd';
alter session set nls_time_format         ='hh24:mi:ssxff';
alter session set nls_time_tz_format      ='hh24:mi:ssxff TZR';
alter session set nls_timestamp_format    ='yyyy-mm-dd hh24:mi:ssxff';
alter session set nls_timestamp_tz_format ='yyyy-mm-dd hh24:mi:ssxff TZR';
set sqlprompt "SQL> "
def x=inc/comment_on
col x new_value x noprint
select 'inc/null' x from dual;
------------------------------------------------
-- Show connect info and set sqlprompt
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
@inc/params_undef
--set timing on
--set serveroutput on

------------------------------------------------
-- Load input params:
def 1 ="&INPUT1"
def 2 ="&INPUT2"
def 3 ="&INPUT3"
def 4 ="&INPUT4"
def 5 ="&INPUT5"
def 6 ="&INPUT6"
def 7 ="&INPUT7"
def 8 ="&INPUT8"
def 9 ="&INPUT9"
def 10="&INPUT10"
def 11="&INPUT11"
def 12="&INPUT12"
def 13="&INPUT13"
def 14="&INPUT14"
def 15="&INPUT15"
def 16="&INPUT16"
def 17="&INPUT17"
def 18="&INPUT18"
def 19="&INPUT19"
def 20="&INPUT20"

set termout on
