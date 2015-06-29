rem Simple example how to get path (@@) of the current script.
rem This script will set "cur_path" variable, so we can use &cur_path later.
 
set termout off
spool _cur_path.remove
@@notfound
spool off;
 
var cur_path varchar2(100);
declare 
  v varchar2(100);
  m varchar2(100):='SP2-0310: unable to open file "';
begin v :=rtrim(ltrim( 
                        q'[
                            @_cur_path.remove
                        ]',' '||chr(10)),' '||chr(10));
  v:=substr(v,instr(v,m)+length(m));
  v:=substr(v,1,instr(v,'notfound.')-1);
  :cur_path:=v;
end;
/
set scan off;
ho "rm _cur_path.remove 2>&1  | echo ."
ho "del _cur_path.remove 2>&1 | echo ."
col cur_path new_val cur_path noprint;
select :cur_path cur_path from dual;
set scan on;
set termout on;
 
prompt Current path: &cur_path