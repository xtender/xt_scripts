prompt * Usage: @unindexed_since 2013-01-01 [owner]

@inc/input_vars_init.sql

col _owner new_val _owner noprint;
select nvl('&2','%') "_owner" from dual;
col _owner clear;


col OWNER           format a12
col TABLE_NAME      format a30
col CONSTRAINT_NAME format a30
col STATE           format a3
col CONSTRAINT_TYPE noprint
col R_COLS          format a50
col COLS            format a50
col INDEXING        noprint

@inc/unindexed_since.inc "&1" "&_owner"

col OWNER           clear
col TABLE_NAME      clear
col CONSTRAINT_NAME clear
col STATE           clear
col CONSTRAINT_TYPE clear
col R_COLS          clear
col COLS            clear
col INDEXING        clear

@inc/input_vars_undef.sql