set head off feed off timing off

col cmd for a250;
select '-- TAB PRIVS: ' cmd from dual union all
select 
  'GRANT ' || tp.privilege ||' ON "'|| tp.owner || '"."' || tp.table_name || '" TO ' || tp.grantee || ';' cmd
from dba_tab_privs tp 
  where tp.grantee = '&1'
 
union all select '-- SYS PRIVS:' from dual union all
select 
  'grant ' || sp.privilege || ' TO ' || sp.grantee || decode(sp.admin_option, 'YES', ' with admin option;', ';')
from dba_sys_privs sp 
where sp.grantee = '&1'

union all select '-- ROLE PRIVS: ' from dual union all
select 
  'GRANT ' || rp.granted_role || ' TO ' || rp.grantee || decode(rp.admin_option, 'YES', ' with admin option;', ';')
from dba_role_privs rp 
where rp.grantee = '&1'
/
col cmd clear;
set head on feed on;