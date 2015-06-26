set termout off
spool def.txt
def
spool off;
set termout on;
ho "cat def.txt 2>nul | grep -v "DEFINE _C" 2>nul"
ho "rm def.txt"
