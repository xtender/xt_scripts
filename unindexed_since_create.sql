prompt Usage: @unindexed_since_create 2013-01-01 [owner]
@inc/input_vars_init.sql

col _owner new_val _owner noprint;
select nvl('&2','%') "_owner" from dual;
col _owner clear;

set head off feed off
col OWNER           noprint
col TABLE_NAME      noprint
col CONSTRAINT_NAME noprint
col LAST_CHANGE     noprint
col STATE           noprint
col CONSTRAINT_TYPE noprint
col R_COLS          noprint
col COLS            noprint
col INDEXING        format a200

spool &_SPOOLS./indexes_creation.sql

@inc/unindexed_since.inc "&1" "&_owner"
spool off;
ho &_START &_SPOOLS./indexes_creation.sql

col OWNER           clear
col TABLE_NAME      clear
col CONSTRAINT_NAME clear
col LAST_CHANGE     clear
col STATE           clear
col CONSTRAINT_TYPE clear
col R_COLS          clear
col COLS            clear
col INDEXING        clear

@inc/input_vars_undef.sql