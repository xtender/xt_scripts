col tracedir new_value tracedir for a120;
select value tracedir from v$diag_info where name = 'Diag Trace';

accept dir  prompt 'Enter directory path: ';
accept mask prompt 'Enter file name mask[%]: ' default '%';
accept cnt  prompt 'Number of files to show[0 - to show all]: ' default 0;

set serverout on;

declare
   PROCEDURE LIST_FILES (directory_path IN VARCHAR2, file_name_mask in VARCHAR2)
   AS
      dir   VARCHAR2(1024):=directory_path;
      lv_ns VARCHAR2(1024);
   BEGIN

      SYS.DBMS_BACKUP_RESTORE.SEARCHFILES(dir, lv_ns);
    
      FOR file_list IN (
         SELECT FNAME_KRBMSFT AS file_name
         FROM sys.X$KRBMSFT
         WHERE FNAME_KRBMSFT LIKE '%'|| file_name_mask ||'%'
         and (&cnt=0 or rownum<=&cnt)
      ) 
      LOOP
         dbms_output.put_line(file_list.file_name);
      END LOOP;
    
   END;
begin
   list_files('&dir','&mask');
end;
/
set serverout off
