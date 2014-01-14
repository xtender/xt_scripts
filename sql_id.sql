@inc/input_vars_init;

def _sql_id_1="&1"
def _sql_id_2="&2"


prompt &_C_RED####################################################################################################;
prompt #               Show SQL text, child cursors and execution stats for SQLID &1 child &2
prompt ####################################################################################################&_C_RESET

REM ################### SHOW SQL TEXT ############################
@sql_text "&_sql_id_1"

REM ################### SHOW  V$SQL ##############################
@sql_stat "&_sql_id_1" "&_sql_id_2"

REM ################### PLSQL OBJECT ##############################
@sql_plsql_obj "&_sql_id_1"

REM ################### SQL_MONITOR ######################
@if "'&_O_RELEASE'>'11.2'" then
   
   @rtsm/execs "&_sql_id_1" "and sql_exec_start>sysdate-2/24 and rownum<20" "" "" "" ""
   
/* end if */

REM ################### clear ############################

undef _sql_id_1;
undef _sql_id_2;
@inc/input_vars_undef;