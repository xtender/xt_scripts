create or replace directory AWR_DATA as '&path_to_awrdata';

declare
   sched_action varchar2(32767):= q'[
      declare
        awr_file     varchar2(30);
        awr_dir      varchar2(30):='AWR_DATA';
        awr_beg_snap number;
        awr_end_snap number;
        awr_dbid     number;
        dbname       varchar2(30);
      begin
         select dbid,name 
           into awr_dbid, dbname
         from v$database;
         
         select min(snap_id),max(snap_id)
           into awr_beg_snap,awr_end_snap
         from dba_hist_snapshot sn 
         where dbid=awr_dbid
           and end_interval_time between systimestamp - interval '7' day and systimestamp;

         awr_file:='awr_'||dbname||'_'||to_char(sysdate,'yyyymmdd')||'_'||awr_beg_snap||'_'||awr_end_snap;

        /* call PL/SQL routine to extract the data */
        dbms_swrf_internal.awr_extract(dmpfile  => awr_file,
                                       dmpdir   => awr_dir,
                                       bid      => awr_beg_snap,
                                       eid      => awr_end_snap,
                                       dbid     => awr_dbid
                                      );
        dbms_swrf_internal.clear_awr_dbid;
      end;
   ]';
begin
  DBMS_SCHEDULER.create_job (
    job_name        => 'AWR_EXTRACT_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => sched_action,
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'freq=weekly; byday=mon; byhour=0; byminute=15; bysecond=0;',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'Extract AWR DATA to dumpfile.');
end;
/
