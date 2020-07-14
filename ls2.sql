--set serverout on;
accept _dir_name prompt "Directory name: ";
accept _f_mask prompt "File mask: ";
accept _max_files prompt "Max number of files to output[100] :" default 100;
declare
   PROCEDURE LIST_FILES (dir_name in varchar2, file_mask IN VARCHAR2 default null, max_files in number default 100)
   AS
      lv_pattern VARCHAR2(1024);
      lv_ns VARCHAR2(1024);
   BEGIN
      SELECT directory_path
      INTO lv_pattern
      FROM dba_directories
      WHERE directory_name LIKE list_files.dir_name;
    
      SYS.DBMS_BACKUP_RESTORE.SEARCHFILES(lv_pattern, lv_ns);
    
      FOR file_list IN (
      ) 
      LOOP
         dbms_output.put_line(file_list.file_name);
      END LOOP;
    
   END;
begin
   list_files('&_dir_name', '&_f_mask', &_max_files);
end;
/
--set serverout off

SELECT FNAME_KRBMSFT AS file_name
FROM sys.X$KRBMSFT
WHERE FNAME_KRBMSFT LIKE '%&_f_mask%'
and rownum< &_max_files;

SELECT count(*) cnt
FROM sys.X$KRBMSFT
WHERE FNAME_KRBMSFT LIKE '%&_f_mask%';
