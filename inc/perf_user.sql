set echo off;
prompt *******************************************************************************************
prompt *** Creating a standalone user for performance tuning and troubleshooting,
prompt *   using standard roles, requires creating v$ views for several fixed tables (x$).
prompt *******************************************************************************************

accept uname prompt "Username: ";
accept upass prompt "Password: ";

set echo on feed on ver off;

CREATE USER &uname
  IDENTIFIED BY "&upass";

-- 1 Tablespace Quota for &uname 
-- ALTER USER &uname QUOTA UNLIMITED ON TOOLS;

-- 6 Roles for the perf user
GRANT CONNECT                  TO &uname;
GRANT SELECT_CATALOG_ROLE      TO &uname;
GRANT OEM_ADVISOR              TO &uname;
GRANT OEM_MONITOR              TO &uname;
GRANT GATHER_SYSTEM_STATISTICS TO &uname;
-- Excluded DBA role for some reasons...
--GRANT DBA                      TO &uname;
ALTER USER &uname DEFAULT ROLE ALL;

-- 14 System Privileges for the perf user
GRANT SELECT ANY DICTIONARY TO &uname;
GRANT ANALYZE ANY TO &uname;
GRANT ADMINISTER SQL MANAGEMENT OBJECT TO &uname;
GRANT ALTER ANY SQL PROFILE TO &uname;
GRANT DROP ANY SQL PROFILE TO &uname;
GRANT ADVISOR TO &uname;
GRANT CREATE ANY JOB TO &uname;
GRANT RESTRICTED SESSION TO &uname;
GRANT ADMINISTER ANY SQL TUNING SET TO &uname;
GRANT ADMINISTER SQL TUNING SET TO &uname;
GRANT CREATE PROCEDURE TO &uname;
GRANT SELECT ANY TABLE TO &uname;
GRANT CREATE ANY SQL PROFILE TO &uname;
GRANT CREATE TABLE TO &uname;

-- Object Privileges for &uname 
GRANT SELECT  ON SYS.DBA_HIST_SNAPSHOT TO &uname;
GRANT EXECUTE ON SYS.DBMS_AUTO_SQLTUNE TO &uname;
GRANT EXECUTE ON SYS.DBMS_LOCK TO &uname;
GRANT EXECUTE ON SYS.DBMS_MONITOR TO &uname;
GRANT EXECUTE ON SYS.DBMS_RESULT_CACHE TO &uname;
GRANT EXECUTE ON SYS.DBMS_SHARED_POOL TO &uname;
GRANT EXECUTE ON SYS.DBMS_SQLPA TO &uname;
GRANT EXECUTE ON SYS.DBMS_WORKLOAD_REPOSITORY TO &uname;
--GRANT EXECUTE ON SYS.DEBUG_VERSION_RPT TO &uname;
--GRANT SELECT  ON SYS.H$PSEUDO_CURSOR TO &uname;
--GRANT EXECUTE ON SYS.VERSION_RPT TO &uname;
GRANT SELECT ON SYS.VX$BH TO &uname;
GRANT SELECT ON SYS.VX$K2GTE2 TO &uname;
GRANT SELECT ON SYS.VX$KGLCURSOR TO &uname;
GRANT SELECT ON SYS.VX$KGLLK TO &uname;
GRANT SELECT ON SYS.VX$KGLOB TO &uname;
GRANT SELECT ON SYS.VX$KGLPN TO &uname;
GRANT SELECT ON SYS.VX$KSLLD TO &uname;
GRANT SELECT ON SYS.VX$KSLLTR_CHILDREN TO &uname;
GRANT SELECT ON SYS.VX$KSLLTR_PARENT TO &uname;
GRANT SELECT ON SYS.VX$KSLLW TO &uname;
GRANT SELECT ON SYS.VX$KSMHP TO &uname;
GRANT SELECT ON SYS.VX$KSPPCV TO &uname;
GRANT SELECT ON SYS.VX$KSPPI TO &uname;
GRANT SELECT ON SYS.VX$KSPVLD_VALUES TO &uname;
GRANT SELECT ON SYS.VX$KSUPR TO &uname;
GRANT SELECT ON SYS.VX$KSUPRLAT TO &uname;
GRANT SELECT ON SYS.VX$KSUSE TO &uname;
GRANT SELECT ON SYS.VX$KTCXB TO &uname;
GRANT SELECT ON SYS.V_$PROCESS TO &uname;
GRANT SELECT ON SYS.V_$SESSION TO &uname;

set echo off;

prompt *******************************************************************************************
prompt * Done.
prompt *******************************************************************************************