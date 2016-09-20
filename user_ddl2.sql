set feed off head off
define username='&1';

begin
   dbms_metadata.set_transform_param(dbms_metadata.SESSION_TRANSFORM, 'PRETTY'       , true);
   dbms_metadata.set_transform_param(dbms_metadata.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
end;
/
col ddl for a1500;

select to_clob('/* User &username: */') as ddl from dual
union all select ltrim(dbms_metadata.get_ddl( 'USER', '&username' ),chr(10)) as ddl from dual
union all select to_clob('/* Roles:         */') as ddl from dual
union all select ltrim(dbms_metadata.get_granted_ddl( 'ROLE_GRANT'      , '&username'),chr(10)) as ddl from dual
union all select to_clob('/* default role   */') as ddl from dual
union all select ltrim(dbms_metadata.get_granted_ddl( 'DEFAULT_ROLE'    , '&username'),chr(10)) as ddl from dual
union all select to_clob('/* System grants: */') as ddl from dual
union all select ltrim(dbms_metadata.get_granted_ddl( 'SYSTEM_GRANT'    , '&username'),chr(10)) as ddl from dual
union all select to_clob('/* Obj. grants:   */') as ddl from dual
union all select ltrim(dbms_metadata.get_granted_ddl( 'OBJECT_GRANT'    , '&username'),chr(10)) as ddl from dual
union all select to_clob('/* TS quotas:     */') as ddl from dual
union all select ltrim(dbms_metadata.get_granted_ddl( 'TABLESPACE_QUOTA', tq.username)) as ddl from dba_ts_quotas tq where '&username'=tq.username
/
col ddl clear;
set feed on head on;
