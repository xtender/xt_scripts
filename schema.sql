col current_schema for a30;
accept schema_name default '&1' prompt "Schema name[&1]: ";
alter session set current_schema=&schema_name;
select sys_context('USERENV', 'current_schema') current_schema from dual;