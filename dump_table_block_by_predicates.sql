accept TABLE_NAME prompt "Table name: ";
accept PREDICATES prompt "Predicates[1=1]: " default '1=1';

set head off;
spool dump.tmp
with blocks as (
   select distinct
      dbms_rowid.rowid_relative_fno(t.rowid) file_id
    , dbms_rowid.rowid_block_number(t.rowid) block
   from &TABLE_NAME t
   where &PREDICATES
)
select 
   'alter system dump datafile '||to_char(b.file_id,'TM9')
     ||' block '||to_char(b.block)||';' cmd
from blocks b;
spool off;
prompt Dump commands were saved to dump.tmp;
accept _tmp prompt "Do you want to execute it? [Y/n]: " default 'n';

col scr new_val _scr noprint;
select case when upper('&_tmp')='Y' then 'dump.tmp' else 'inc/null.sql' end as scr 
from dual;

@&_scr;

col tracefile_name for a120;
select 
      'Now you have to reconnect. Dump saved into: '||chr(10)
     ||(SELECT VALUE FROM V$DIAG_INFO WHERE NAME = 'Default Trace File') 
     as tracefile_name 
from dual
where upper('&_tmp')='Y';

col scr clear;
col tracefile_name clear;

undef _scr;
undef TABLE_NAME;
undef PREDICATES;
alter session set tracefile_identifier=CLEANUP;
alter session set tracefile_identifier=new;
set head on;

