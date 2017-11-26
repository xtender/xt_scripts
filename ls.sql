set serverout on;

declare
   PROCEDURE LIST_FILES (lp_string IN VARCHAR2 default null)
   AS
      lv_pattern VARCHAR2(1024);
      lv_ns VARCHAR2(1024);
   BEGIN
      SELECT directory_path
      INTO lv_pattern
      FROM dba_directories
      WHERE directory_name = '&1';
    
      SYS.DBMS_BACKUP_RESTORE.SEARCHFILES(lv_pattern, lv_ns);
    
      FOR file_list IN (
         SELECT FNAME_KRBMSFT AS file_name
         FROM sys.X$KRBMSFT
         WHERE FNAME_KRBMSFT LIKE '%'|| lp_string||'%'
      ) 
      LOOP
         dbms_output.put_line(file_list.file_name);
      END LOOP;
    
   END;
begin
   list_files('');
end;
/
set serverout off
