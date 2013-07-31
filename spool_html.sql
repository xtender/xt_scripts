@sqlplus_store;

def _OUT_FILE_NAME   ="tmp_htm_&DB_NAME.-&MY_SID.-&MY_SERIAL.-&MY_SPID..html";
def _SCRIPT_FILE_NAME="tmp_htm_&DB_NAME.-&MY_SID.-&MY_SERIAL.-&MY_SPID..sql"
save &_SCRIPT_FILE_NAME replace;


set term off feed off timing off numformat 999,999,999,999.999
set markup HTML ON HEAD "                                                       -
<style type='text/css'>                                                         -
   body {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;}  -
   p {   font:10pt Arial,Helvetica,sans-serif; color:black; background:White;}  -
                                                                                -
   table,tr,td {                                                                -
         font:10pt Arial,Helvetica,sans-serif; color:Black; background:white;   -
         border-color: #a9c6c9;                                                 -
         padding:0px 0px 0px 0px; margin:0px 0px 0px 0px; white-space:nowrap;   -
   }                                                                            -
   th {  font:bold 10pt Arial,Helvetica,sans-serif;                             -
         color:#336699; background:#d4e3e5;                                     -
         padding:0px 0px 0px 0px;                                               -
   }                                                                            -
   h1 {  font:16pt Arial,Helvetica,Geneva,sans-serif; color:#336699;            -
         background-color:White;                                                -
         border-bottom:1px solid #cccc99;                                       -
         margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;            -
   }                                                                            -
   h2 {  font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699;       -
         background-color:White;                                                -
         margin-top:4pt; margin-bottom:0pt;                                     -
   }                                                                            -
   a  {  font:9pt Arial,Helvetica,sans-serif; color:#663300;                    -
         background:#ffffff;                                                    -
         margin-top:0pt; margin-bottom:0pt; vertical-align:top;                 -
   }                                                                            -
</style>                                                                        -
<title>Temp html output</title>      " -
BODY "" -
TABLE "border='1' align='center' summary='Script output'" -
SPOOL ON ENTMAP ON PREFORMAT OFF;
spool &_SPOOLS./&_OUT_FILE_NAME;
list
/
spool off
set markup html off spool off
host &_START &_SPOOLS.&_OUT_FILE_NAME;
@sqlplus_restore;