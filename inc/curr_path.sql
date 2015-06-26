rem Simple example how to get path (@@) of the current script
rem This script will set cur_path variable - &cur_path

set termout off
spool _cur_path.remove
@@notfound
spool off;


ho "cat _cur_path.remove 2>nul | sed 's#SP2-0310: unable to open file .##g' | sed 's#notfound.sql.##g' >_cur_path.remove"

var cur_path varchar2(100);
begin :cur_path :=rtrim(ltrim( 
                        q'[
                            @_cur_path.remove
                        ]',' '||chr(10)),' '||chr(10));
end;
/
ho "rm _cur_path.remove"
col cur_path new_val cur_path noprint;
select :cur_path cur_path from dual;
set termout on;

prompt Current path: &cur_path