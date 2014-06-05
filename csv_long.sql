def  tmp_file=&_TEMPDIR./tmp-&_USER.[&_CONNECT_IDENTIFIER]-&MY_SID-&MY_SERIAL-&MY_OS_PID
save &tmp_file..sql replace

set termout off
REM ##### DEFAULT Separator #######
REM def _SEP = ","
def _SEP = ";"
REM ##### SET Separator ###########

set feedback off colsep "&_SEP" lines 32767 trimspool on trimout on tab off underline on pages 50000 head on
get &tmp_file
spool &tmp_file..csv
l
/
spool off

host &_start &tmp_file..csv

rem host rm  &tmp_file..sql
rem host del &tmp_file..sql

undef _SEP
set lines 1500;