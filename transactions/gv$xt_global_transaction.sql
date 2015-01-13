create or replace view gv$xt_global_transaction(INST_ID, FORMATID, GLOBALID, BRANCHID, BRANCHES, REFCOUNT, PREPARECOUNT, STATE, FLAGS, COUPLING, saddr, globalid_ora)
as
SELECT 
      g."INST_ID"      "INST_ID"
     ,g."K2GTIFMT"     "FORMATID"
     ,g."K2GTITID_EXT" "GLOBALID"
     ,g."K2GTIBID"     "BRANCHID"
     ,g."K2GTECNT"     "BRANCHES"
     ,g."K2GTERCT"     "REFCOUNT"
     ,g."K2GTDPCT"     "PREPARECOUNT"
     ,DECODE(g."K2GTDFLG"
            ,0                   ,'ACTIVE'
            ,1                   ,'COLLECTING'
            ,2                   ,'FINALIZED'
            ,4                   ,'FAILED'
            ,8                   ,'RECOVERING'
            ,16                  ,'UNASSOCIATED'
            ,32                  ,'FORGOTTEN'
            ,64                  ,'READY FOR RECOVERY'
            ,128                 ,'NO-READONLY FAILED'
            ,256                 ,'SIBLING INFO WRITTEN'
            ,512                 ,'[ORACLE COORDINATED]ACTIVE'
            ,512 + 1             ,'[ORACLE COORDINATED]COLLECTING'
            ,512 + 2             ,'[ORACLE COORDINATED]FINALIZED'
            ,512 + 4             ,'[ORACLE COORDINATED]FAILED'
            ,512 + 8             ,'[ORACLE COORDINATED]RECOVERING'
            ,512 + 16            ,'[ORACLE COORDINATED]UNASSOCIATED'
            ,512 + 32            ,'[ORACLE COORDINATED]FORGOTTEN'
            ,512 + 64            ,'[ORACLE COORDINATED]READY FOR RECOVERY'
            ,512 + 128           ,'[ORACLE COORDINATED]NO-READONLY FAILED'
            ,1024                ,'[MULTINODE]ACTIVE'
            ,1024 + 1            ,'[MULTINODE]COLLECTING'
            ,1024 + 2            ,'[MULTINODE]FINALIZED'
            ,1024 + 4            ,'[MULTINODE]FAILED'
            ,1024 + 8            ,'[MULTINODE]RECOVERING'
            ,1024 + 16           ,'[MULTINODE]UNASSOCIATED'
            ,1024 + 32           ,'[MULTINODE]FORGOTTEN'
            ,1024 + 64           ,'[MULTINODE]READY FOR RECOVERY'
            ,1024 + 128          ,'[MULTINODE]NO-READONLY FAILED'
            ,1024 + 256          ,'[MULTINODE]SIBLING INFO WRITTEN'
            ,'COMBINATION') "STATE"
     ,g."K2GTDFLG" "FLAGS"
     ,DECODE(g."K2GTETYP"
            ,0            ,'FREE'
            ,1            ,'LOOSELY COUPLED'
            ,2            ,'TIGHTLY COUPLED') "COUPLING"
     -- additional columns:
     ,g.k2gtdses       as saddr
     ,g.k2gtitid_ora   as globalid_ora
FROM   SYS.X$K2GTE2 g
/
create or replace view v$xt_global_transaction as
select FORMATID, GLOBALID, BRANCHID, BRANCHES, REFCOUNT, PREPARECOUNT, STATE, FLAGS, COUPLING, saddr, globalid_ora
from gv$xt_global_transaction
where inst_id = USERENV('INSTANCE')
/
create public synonym gv$xt_global_transaction for gv$xt_global_transaction;
create public synonym  v$xt_global_transaction for  v$xt_global_transaction;
