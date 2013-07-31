def  tmp_file=&_TEMPDIR./tmp-&_USER.[&_CONNECT_IDENTIFIER]-&MY_SID-&MY_SERIAL-&MY_OS_PID
save &tmp_file..sql replace

@inc/input_vars_init
set termout off
REM ##### DEFAULT Separator #######
REM def _SEP = ","
def _SEP = ";"
REM ##### SET Separator ###########

col SEP new_value _SEP
select decode('&1',null,'&_SEP','&1') SEP from dual;
set termout off
set feedback off colsep "&_SEP" lines 32767 trimspool on trimout on tab off underline on
get &tmp_file
spool &tmp_file..csv
l
/
spool off

host &_start &tmp_file..csv

rem host rm  &tmp_file..sql
rem host del &tmp_file..sql

undef _SEP
@inc/input_vars_undef;