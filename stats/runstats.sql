--   FILE:     runstats.sql
--
--
--   AUTHOR:   Tom Kyte
--
--   DATE:     Unknown
--
--   DESCRIPTION:
--             This script installs Tom Kyte's runstats utility. Everything
--             needed to install and run the utility has been included. Since
--             this utility needs certain system privileges it is expected that
--             this utility will be installed into a privileged account.
--
--             The original Runstats is available at:
--               http://asktom.oracle.com/tkyte/runstats.html
--
--   REQUIREMENTS:
--             Requires SELECT privileges on SYS.V_$STATNAME, SYS.V_$MYSTAT,
--             SYS.V_$TIMER and SYS.V_$LATCH.
--             NOTE: These must be DIRECTLY granted privileges, not granted via a ROLE.
--
--             Requires CREATE TABLE privilege to create the run_stats GTT.
--
--             Requires CREATE PROCEDURE to create the package rs_pkg.
--
--             Requires CREATE PUBLIC SYNONYM to create the rs_pkg public synonym.
--
--   MODIFICATIONS:
--             1.0,  01/29/08, A. Rivenes,
--               Initial release.
--             1.1,  01/31/08, A. Rivenes, 
--               Added HIDE feature to suppress password display as they're typed.
--
--
PROMPT >> This script requires an account to install the RUNSTATS utility.
PROMPT >> ;
PROMPT >> Please exit this script (using Control-C or break) if you
PROMPT >> do not wish to continue.
PROMPT >> ;
PROMPT >> Press [Return] to continue.
--
ACCEPT runans
--
ACCEPT runstats_usr prompt 'Enter the ORACLE userid for the RUNSTATS account:  '
PROMPT
ACCEPT runstats_pwd prompt 'Enter the ORACLE password for the RUNSTATS account:  ' HIDE
PROMPT
--
REM Ensure you can connect to the RUNSTATS account using the password given
--
CONNECT &runstats_usr/&runstats_pwd
--
PROMPT >> If the previous connect failed, please exit this script
PROMPT >> (using Control-C or break) and restart, otherwise press [Return]
ACCEPT rinstans
--
-- Insure that system privileges have been granted.
--
PROMPT >> The following system privileges be granted to the runstats schema:
PROMPT >> ;
PROMPT >>   GRANT SELECT ON sys.v_$statname TO runstats_schema;
PROMPT >>   GRANT SELECT ON sys.v_$mystat TO runstats_schema;
PROMPT >>   GRANT SELECT ON sys.v_$timer TO runstats_schema;
PROMPT >>   GRANT SELECT ON sys.v_$latch TO runstats_schema;
PROMPT >>   GRANT CREATE TABLE TO runstats_schema;
PROMPT >>   GRANT CREATE PROCEDURE TO runstats_schema;
PROMPT >>   GRANT CREATE PUBLIC SYNONYM TO runstats_schema;
PROMPT >> ;
PROMPT >> Requires a privileged (SYSDBA) account to create these privileges.
PROMPT >> ;
PROMPT >> Please exit this script (using Control-C or break) if you
PROMPT >> do not wish to continue.
PROMPT >> ;
PROMPT >> Press [Return] to continue.
--
ACCEPT sysans
--
ACCEPT sysdba_usr prompt 'Enter a SYSDBA ORACLE userid:  '
PROMPT
ACCEPT sysdba_pwd prompt 'Enter the SYSDBA ORACLE password:  ' HIDE
PROMPT
--
REM Ensure you can connect to the SYSDBA account using the password given
--
CONNECT &sysdba_usr/&sysdba_pwd AS SYSDBA
--
PROMPT >> If the previous connect failed, please exit this script
PROMPT >> (using Control-C or break) and restart, otherwise press [Return]
ACCEPT sinstans
--
SPOOL sysdba_install.log;
--
-- Grant system privileges
--
GRANT SELECT ON sys.v_$statname TO &runstats_usr;
GRANT SELECT ON sys.v_$mystat TO &runstats_usr;
GRANT SELECT ON sys.v_$timer TO &runstats_usr;
GRANT SELECT ON sys.v_$latch TO &runstats_usr;
GRANT CREATE TABLE TO &runstats_usr;
GRANT CREATE PROCEDURE TO &runstats_usr;
GRANT CREATE PUBLIC SYNONYM TO &runstats_usr;
--
-- Install the runstats utility
--
CONNECT &runstats_usr/&runstats_pwd
--
SPOOL runstats_install.log;
SET SERVEROUTPUT on;
WHENEVER SQLERROR CONTINUE;
--
--set echo on
--
DROP TABLE run_stats;
--
CREATE GLOBAL TEMPORARY TABLE run_stats 
  ( 
    runid varchar2(15), 
    name varchar2(80), 
    value int
  )
ON COMMIT PRESERVE ROWS;
--
CREATE OR REPLACE VIEW stats
AS 
SELECT
  'STAT...' || a.name name, b.value
FROM
  v$statname a,
  v$mystat b
WHERE
  a.statistic# = b.statistic#
UNION ALL
SELECT
  'LATCH.' || name,  gets
FROM
  v$latch
UNION ALL
SELECT
  'STAT...Elapsed Time', 
  hsecs 
FROM
  v$timer;
--
DELETE FROM run_stats;
COMMIT;
--
CREATE OR REPLACE PACKAGE runstats_pkg
AS
  PROCEDURE rs_start;
  --
  PROCEDURE rs_middle;
  --
  PROCEDURE rs_stop(
    p_difference_threshold IN NUMBER DEFAULT 0,
    p_output               IN VARCHAR2 DEFAULT NULL);
  --
  PROCEDURE version;
  --
  PROCEDURE help;
END runstats_pkg;
/
--
CREATE OR REPLACE PACKAGE BODY runstats_pkg
AS
  g_start NUMBER;
  g_run1  NUMBER;
  g_run2  NUMBER;
  --
  g_version_txt   VARCHAR2(60)
        := 'runstats - Version 1.0, January 29, 2008';
  --
  -- Procedure to mark the start of the two runs
  --
  PROCEDURE rs_start
  IS 
  BEGIN
    DELETE FROM run_stats;
    --
    INSERT INTO run_stats 
    SELECT 'before', stats.*
    FROM stats;
    --
    g_start := DBMS_UTILITY.get_time;
  END rs_start;
  --
  -- Procedure to run between the two runs
  --
  PROCEDURE rs_middle
  IS
  BEGIN
    g_run1 := (DBMS_UTILITY.get_time - g_start);
    --
    INSERT INTO run_stats 
    SELECT 'after 1', stats.*
    FROM stats;
    g_start := DBMS_UTILITY.get_time;
  END rs_middle;
  --
  -- Procedure to run after the two runs
  --
  PROCEDURE rs_stop(
    p_difference_threshold IN NUMBER DEFAULT 0,
    p_output               IN VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    g_run2 := (DBMS_UTILITY.get_time - g_start);
    --
    DBMS_OUTPUT.put_line
      ( 'Run1 ran in ' || g_run1 || ' hsecs' );
    DBMS_OUTPUT.put_line
      ( 'Run2 ran in ' || g_run2 || ' hsecs' );
    DBMS_OUTPUT.put_line
      ( 'run 1 ran in ' || ROUND(g_run1/g_run2*100,2) || 
        '% of the time' );
    DBMS_OUTPUT.put_line( CHR(9) );
    --
    INSERT INTO run_stats 
    SELECT 'after 2', stats.*
    FROM stats;
    --
    DBMS_OUTPUT.put_line
    ( rpad( 'Name', 40 ) || lpad( 'Run1', 12 ) || 
      lpad( 'Run2', 12 ) || lpad( 'Diff', 12 ) );
    --
    -- Output choice
    --
    IF p_output = 'WORKLOAD' THEN 
      FOR x IN 
      ( SELECT 
          RPAD( a.name, 40 ) || 
          TO_CHAR( b.value-a.value, '999,999,999' ) || 
          TO_CHAR( c.value-b.value, '999,999,999' ) || 
          TO_CHAR( ( (c.value-b.value)-(b.value-a.value)), '999,999,999' ) data
        FROM
          run_stats a,
          run_stats b,
          run_stats c
        WHERE
           a.name = b.name
           AND b.name = c.name
           AND a.runid = 'before'
           AND b.runid = 'after 1'
           AND c.runid = 'after 2'
           AND ABS( (c.value-b.value) - (b.value-a.value) ) 
             > p_difference_threshold
           AND c.name IN
            (
              'STAT...Elapsed Time',
              'STAT...DB Time',
              'STAT...CPU used by this session',
              'STAT...parse time cpu',
              'STAT...recursive cpu usage',
              'STAT...session logical reads',
              'STAT...physical reads',
              'STAT...physical reads cache',
              'STAT...physical reads direct',
              'STAT...sorts (disk)',
              'STAT...sorts (memory)',
              'STAT...sorts (rows)',
              'STAT...queries parallelized',
              'STAT...redo size',
              'STAT...user commits'
            )
         ORDER BY
           ABS( (c.value-b.value)-(b.value-a.value))
      ) LOOP
        DBMS_OUTPUT.put_line( x.data );
      END LOOP;
    ELSE
      -- Assume the default of NULL, all stats will be displayed
      FOR x IN 
      ( SELECT 
          RPAD( a.name, 40 ) || 
          TO_CHAR( b.value-a.value, '999,999,999' ) || 
          TO_CHAR( c.value-b.value, '999,999,999' ) || 
          TO_CHAR( ( (c.value-b.value)-(b.value-a.value)), '999,999,999' ) data
        FROM
          run_stats a,
          run_stats b,
          run_stats c
        WHERE
           a.name = b.name
           AND b.name = c.name
           AND a.runid = 'before'
           AND b.runid = 'after 1'
           AND c.runid = 'after 2'
           AND ABS( (c.value-b.value) - (b.value-a.value) ) 
             > p_difference_threshold
         ORDER BY
           ABS( (c.value-b.value)-(b.value-a.value))
      ) LOOP
        DBMS_OUTPUT.put_line( x.data );
      END LOOP;
    END IF;
    --
    DBMS_OUTPUT.put_line( CHR(9) );
    DBMS_OUTPUT.put_line
      ( 'Run1 latches total versus runs -- difference and pct' );
    DBMS_OUTPUT.put_line
      ( lpad( 'Run1', 12 ) || lpad( 'Run2', 12 ) || 
        lpad( 'Diff', 12 ) || lpad( 'Pct', 10 ) );
    --
    FOR x IN 
    ( SELECT
        TO_CHAR( run1, '999,999,999' ) ||
        TO_CHAR( run2, '999,999,999' ) ||
        TO_CHAR( diff, '999,999,999' ) ||
        TO_CHAR( round( run1/run2*100,2 ), '99,999.99' ) || '%' data
      FROM 
        (
          SELECT
            SUM(b.value-a.value) run1,
            SUM(c.value-b.value) run2,
            SUM( (c.value-b.value)-(b.value-a.value)) diff
          FROM
            run_stats a,
            run_stats b,
            run_stats c
          WHERE
            a.name = b.name
            AND b.name = c.name
            AND a.runid = 'before'
            AND b.runid = 'after 1'
            AND c.runid = 'after 2'
            AND a.name like 'LATCH%'
        )
    ) LOOP
      DBMS_OUTPUT.put_line( x.data );
    END LOOP;
  END rs_stop;
  --
  -- Display version
  --
  PROCEDURE version
  IS
  -- 
  BEGIN
    IF LENGTH(g_version_txt) > 0 THEN
      dbms_output.put_line(' ');
      dbms_output.put_line(g_version_txt);
    END IF;
  -- 
  END version;
  --
  -- Display help
  --
  PROCEDURE help 
  IS
  -- 
  -- Lists help menu
  --
  BEGIN
    DBMS_OUTPUT.put_line(CHR(9));
    DBMS_OUTPUT.PUT_LINE(g_version_txt);
    DBMS_OUTPUT.put_line(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Procedure rs_start');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'Run to mark the start of the test');
    DBMS_OUTPUT.put_line(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Procedure rs_middle');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'Run to mark the middle of the test');
    DBMS_OUTPUT.put_line(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Procedure rs_stop');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'Run to mark the end of the test');
    DBMS_OUTPUT.put_line(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Parameters:');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'p_difference_threshold - Controls the output. Only stats greater');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'than p_difference_threshold will be displayed.');
    DBMS_OUTPUT.put_line(CHR(9));
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'p_output - Controls stats displayed.');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'  Default is NULL, all stats displayed.');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'  WORKLOAD, only workload related stats are displayed.');
    --
    DBMS_OUTPUT.put_line(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Example:');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'Add the following calls to your test code:');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'    exec runStats_pkg.rs_start;');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'    exec runStats_pkg.rs_middle;');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'    exec runStats_pkg.rs_stop;');
    --
    DBMS_OUTPUT.put_line(CHR(9));
    DBMS_OUTPUT.PUT_LINE('NOTE: In SQL*Plus set the following for best results:');
    DBMS_OUTPUT.put_line(CHR(9));
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'Before 10g:   SET SERVEROUTPUT ON SIZE 1000000');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'10g or later: SET SERVEROUTPUT ON');
  END help;
  --
END runstats_pkg;
/
--
-- Grant privileges on runstats objects
--
SET escape "^";
CREATE PUBLIC SYNONYM runstats_pkg FOR &runstats_usr^.runstats_pkg;
GRANT EXECUTE ON runstats_pkg TO PUBLIC;
--
EXIT;

