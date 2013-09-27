col admin_option format a15;
col default_role format a15;
col os_granted   format a15;
select 
--    rpad('  ',2*level,'..')||p.GRANTEE grantee
    rpad('  ',2*level,'..')||p.GRANTED_ROLE GRANTED_ROLE
--   ,p.GRANTED_ROLE
   ,p.ADMIN_OPTION
   ,p.DEFAULT_ROLE 
from dba_role_privs p
start with p.grantee in ('SCOTT','PUBLIC')
connect by prior p.GRANTED_ROLE=p.grantee
order siblings by p.granted_role;

col admin_option clear;
col default_role clear;
col os_granted   clear;

col grantable    format a15;
col hierarhy     format a15;
select 
    p.grantee
   ,p.table_schema||'.'||p.TABLE_NAME object
   ,p.grantor
   ,p.privilege
   ,p.grantable
   ,p.hierarchy 
from all_tab_privs p
where --p.grantee='PUBLIC' and 
  p.table_name like 'V$%'
order by grantee,object;

select * from user_col_privs;

col grantable    clear;
col hierarhy     clear;