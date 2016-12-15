col ddl for a200;
select 
   'Grant '
  ||listagg(privilege,',') within group(order by privilege)
  ||' on directory '|| p.owner||'.'||table_name||' to '||grantee
  ||decode(grantable,'YES',' with grant option')
  ||';' ddl
from dba_directories d, dba_tab_privs p
where d.owner          = p.owner
  and d.directory_name = p.table_name
group by p.owner,p.table_name,p.grantee,p.grantable
order by p.owner,p.table_name,p.grantee
/
col ddl clear;
