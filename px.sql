col f format a2
col inst_id         format 99
col QCSERIAL#       noprint;
col QCINST_ID       noprint;
col SERVER_GROUP    head SGRP;
col SERVER_SET      head SSET;
col SERVER#         head S#;
col username    format a20;
col terminal    format a20;
col osuser      format a20;
col wait_class  format a20;
col event       format a60;
col SADDR       noprint;
select 
     decode(px.sid,px.qcsid,'QC','  ') F
    ,px.*
    ,ss.sql_id
    ,ss.username
    ,ss.terminal
    ,ss.osuser
    ,ss.wait_class
    ,ss.event 
from gv$px_session px,gv$session ss
where px.inst_id = ss.inst_id(+)
and px.sid       = ss.sid(+)
order by px.qcsid,f nulls last
        ,px.SERVER_GROUP
        ,px.SERVER_SET
        ,px.SERVER#
;
col username clear;
col terminal clear;
col SADDR       clear;