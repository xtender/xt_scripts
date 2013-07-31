alter session set db_file_multiblock_read_count=512;
create index SYS.IX_WRH$_SQL_PLAN_OBJ#      on SYS.WRH$_SQL_PLAN(OBJECT#)                  tablespace ix_users2 online;
create index SYS.IX_WRH$_SQL_PLAN_OWNER_OBJ on SYS.WRH$_SQL_PLAN(OBJECT_OWNER,OBJECT_NAME) tablespace ix_users2 online;
