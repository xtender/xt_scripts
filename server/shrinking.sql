set serverout on;
declare
  vunf number;
  vunfb number;
  vfs1 number;
  vfs1b number;
  vfs2 number;
  vfs2b number;
  vfs3 number;
  vfs3b number;
  vfs4 number;
  vfs4b number;
  vfull number;
  vfullb number;
begin
   dbms_space.space_usage(upper('&1'),upper('&2'),
                           'TABLE',
                           vunf, vunfb,
                           vfs1, vfs1b,
                           vfs2, vfs2b,
                           vfs3, vfs3b,
                           vfs4, vfs4b,
                           vfull,vfullb
   );
   dbms_output.put_line(
     'FILLING '
     ||lpad('unformatted',15)
     ||lpad('0%-25%'     ,15)
     ||lpad('25%-50%'    ,15)
     ||lpad('50%-75%'    ,15)
     ||lpad('75%-100%'   ,15)
     ||lpad('full'       ,15)
   );
   dbms_output.put_line(
     'BLOCKS  '
     ||lpad(to_char(vunf ,'999999999999999'),15)
     ||lpad(to_char(vfs1 ,'999999999999999'),15)
     ||lpad(to_char(vfs2 ,'999999999999999'),15)
     ||lpad(to_char(vfs3 ,'999999999999999'),15)
     ||lpad(to_char(vfs4 ,'999999999999999'),15)
     ||lpad(to_char(vfull,'999999999999999'),15)
   );
   dbms_output.put_line(
     'BYTES   '
     ||lpad(to_char(vunfb ,'999999999999999'),15)
     ||lpad(to_char(vfs1b ,'999999999999999'),15)
     ||lpad(to_char(vfs2b ,'999999999999999'),15)
     ||lpad(to_char(vfs3b ,'999999999999999'),15)
     ||lpad(to_char(vfs4b ,'999999999999999'),15)
     ||lpad(to_char(vfullb,'999999999999999'),15)
   );
end;
/
set serverout off;