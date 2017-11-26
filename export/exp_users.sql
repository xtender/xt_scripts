set echo off feed off head off;
begin
   DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
   DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
end;
/
select 
  dbms_metadata.get_ddl('USER',username) ddl
from dba_users u 
where ACCOUNT_STATUS='OPEN' 
--and inherited='NO'
and oracle_maintained='N'
--and common='NO' 
/
set feed on head on;
