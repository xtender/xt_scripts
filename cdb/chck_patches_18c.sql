-- -----------------------------------------------------------------------------------
-- File Name    : https://MikeDietrichDE.com/wp-content/scripts/18c/check_patchesi_18.sql
-- Author       : Mike Dietrich 
-- Description  : Displays contents of the patches (BP/PSU) registry and history
-- Requirements : Access to the DBA role.
-- Call Syntax  : @check_patches_18.sql
-- Last Modified: 24/07/2018
-- Database Rel.: Oracle 12.2.0.1, Oracle 18c, Oracle 19c
-- -----------------------------------------------------------------------------------

SET LINESIZE 500
SET PAGESIZE 1000
SET SERVEROUT ON
SET LONG 2000000

COLUMN action_time FORMAT A12
COLUMN action FORMAT A10
COLUMN patch_type FORMAT A10
COLUMN description FORMAT A32
COLUMN status FORMAT A10
COLUMN version FORMAT A10

alter session set "_exclude_seed_cdb_view"=FALSE;

spool check_patches_18.txt

 select CON_ID,
        TO_CHAR(action_time, 'YYYY-MM-DD') AS action_time,
        PATCH_ID,
        PATCH_TYPE,
        ACTION,
        DESCRIPTION,
        SOURCE_VERSION,
        TARGET_VERSION
   from CDB_REGISTRY_SQLPATCH
  order by CON_ID, action_time, patch_id;

 
