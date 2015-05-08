col SNAP_INTERVAL   format a21;
col RETENTION       format a21;

select * from dba_hist_wr_control;

col SNAP_INTERVAL   clear;
col RETENTION       clear;