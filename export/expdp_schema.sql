accept _SCHEMA prompt "Enter Schema name for export: ";

set serverout on feed on;

declare

    PROCEDURE exp_schema(p_schema_name IN VARCHAR2)
    IS

        v_sid            VARCHAR2(200); -- sid for this databaes
        v_handle         NUMBER; -- job handle
        v_current_time   DATE := SYSDATE; -- consistent timestamp for files, job_name etc.
        v_start_time     DATE; -- start time for log file
        v_logfile_name   VARCHAR2(200); -- logfile name
        v_dumpfile_name  VARCHAR2(200); -- logfile name
        v_default_dir    VARCHAR(30) := 'DATA_PUMP_DIR'; -- directory
        v_degree         INTEGER := 1; -- degree of parallelism
        v_line_no        INTEGER := 0; -- debug line no
        v_sqlcode        NUMBER; -- sqlcode
        v_compatible     VARCHAR2(40) := 'COMPATIBLE'; -- default is 'COMPATIBLE'
        vc_job_mode      CONSTANT VARCHAR2(200) := 'SCHEMA'; -- Job mode
        v_filter_name    VARCHAR2(30); -- filter name
        v_filter_value   NUMBER; -- filter value
    BEGIN
        SELECT name INTO v_sid FROM v$database;
        v_line_no := 100; -- debug line no

        IF v_compatible = 'COMPATIBLE'
        THEN
            v_logfile_name := 'expdp_' || v_sid || '_' || TO_CHAR(v_current_time, 'YYYY_MMDD_HH24MI') || '.log';
            v_dumpfile_name := 'expdp_' || v_sid || '_%U_' || TO_CHAR(v_current_time, 'YYYY_MMDD_HH24MI') || '.dmp';
        ELSE
            v_logfile_name := 'expdp_' || v_sid || '_' || TO_CHAR(v_current_time, 'YYYY_MMDD_HH24MI') || '_' || v_compatible || '.log';
            v_dumpfile_name := 'expdp_' || v_sid || '_%U_' || TO_CHAR(v_current_time, 'YYYY_MMDD_HH24MI') || '_' || v_compatible || '.dmp';
        END IF;

        -- Open the job
        BEGIN
            v_handle :=
                DBMS_DATAPUMP.open(operation => 'EXPORT',
                                   job_mode  => vc_job_mode,
                                   job_name  => 'EXPORT_' || vc_job_mode || '_' || TO_CHAR(v_current_time, 'YYYY_MMDD_HH24MI_SS'),
                                   version   => v_compatible);
        EXCEPTION
            WHEN OTHERS
            THEN
                DBMS_OUTPUT.put_line(SUBSTR('Failure in dbms_datapump.open', 1, 255));
                RAISE;
        END;

        v_line_no := 200; -- debug line no

        -- Set the degree
        -- DBMS_DATAPUMP.set_parallel(handle => v_handle, degree => v_degree);

        -- Add a logfile
        DBMS_DATAPUMP.add_file(handle => v_handle,
                               filename => v_logfile_name,
                               directory => v_default_dir,
                               filetype => DBMS_DATAPUMP.ku$_file_type_log_file);
        v_line_no := 400; -- debug line no
        -- Add a datafile
        DBMS_DATAPUMP.add_file(handle => v_handle,
                               filename => 'dp' || '_%U_' || v_dumpfile_name,
                               directory => v_default_dir,
                               filetype => DBMS_DATAPUMP.ku$_file_type_dump_file);
        v_line_no := 500; -- debug line no

        DBMS_DATAPUMP.metadata_filter(handle => v_handle, name => 'SCHEMA_LIST', VALUE => '''' || p_schema_name || '''');
        v_line_no := 600; -- debug line no

        -- Get the start time
        v_start_time := SYSDATE;

        v_line_no := 700; -- debug line no

        -- Add a start time to the log file
        DBMS_DATAPUMP.log_entry(handle => v_handle, MESSAGE => 'Job Start at ' || TO_CHAR(v_start_time, 'DD-Mon-RR HH24:MI:SS'), log_file_only => 0);

        v_line_no := 710; -- debug line no
        -- Start the job
        DBMS_DATAPUMP.start_job(handle => v_handle);
        DBMS_DATAPUMP.detach(handle => v_handle);
        v_line_no := 800; -- debug line no
    EXCEPTION
        WHEN OTHERS
        THEN

            BEGIN
                DBMS_DATAPUMP.detach(handle => v_handle);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            DBMS_OUTPUT.put_line(SUBSTR('Value of v_line_no=' || TO_CHAR(v_line_no), 1, 255));
            RAISE;
    END exp_schema; -- Procedure exp_schema

begin
   exp_schema(upper(q'[&_SCHEMA]'));
end;
/
set serverout off;
