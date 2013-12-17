prompt &_C_REVERSE *** Enable tracing specified query by sid and sql_id
ORADEBUG SETOSPID &OSPID
oradebug TRACEFILE_NAME;
oradebug EVENT sql_trace [sql: sql_id=&SQLID]

prompt Execute "oradebug EVENT sql_trace off;" later for disabling...
