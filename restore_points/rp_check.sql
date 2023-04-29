prompt Contact Sayan about this beforehand to make sure there will be no foreseeable problems.

select log_mode from v$database;
prompt * Must be "ARCHIVELOG"

prompt *****************************************
col value for a120;
select value from v$parameter where name='db_recovery_file_dest';
prompt * Check the path to flash recovery area. It must exist.
prompt *****************************************
show parameter db_recovery_file_dest_size;
prompt *
prompt * This is to check the size of the flash recovery area, if it is too low then we will need to increase it
prompt * SQL> alter system set db_recovery_file_dest_size=100G scope=both;
prompt *****************************************
prompt * In order to roll back to the restore point you need to run the following sql:
prompt * SQL> shutdown immediate;
prompt * SQL> startup mount;
prompt * SQL> FLASHBACK DATABASE TO RESTORE POINT before_upgrade;
prompt *****************************************
prompt * Note that a restore point will grow in size since its creation and thus is more suited for 
prompt * short term roll back plans, and just like a cold backup any work performed on the database 
prompt * after the restore point was created will be lost upon restoring to the restore point.
prompt *****************************************
prompt * To delete the restore point run the following:
prompt * SQL>DROP RESTORE POINT before_upgrade;
prompt *****************************************
@fra;
