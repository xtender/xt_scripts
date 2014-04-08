col time_interval       format a19;
col username            format a25;
col osuser              format a20;
col action              format a25;
col module              format a30;
col sql_exec_start      format a14;
col PHYSICAL_READS      heading "Phy reads";
col PHYSICAL_READ_PCT   format 999.90;
col LOGICAL_READ_PCT    format 999.90;
col PE_OBJECT           format a40;
col PO_OBJECT           format a40;

with v as (
          select--+ no_merge
             begin_time
            ,end_time
            ,intsize_csec/100       as seconds
            ,session_id             as sid
            ,session_serial_num     as serial#
            ,cpu
            ,physical_reads
            ,logical_reads
            ,pga_memory
            ,hard_parses
            ,soft_parses
            ,physical_read_pct
            ,logical_read_pct
            ,dense_rank()over(order by cpu            desc) cpu_rnk
            ,dense_rank()over(order by physical_reads desc) phy_reads_rnk
            ,dense_rank()over(order by logical_reads  desc) logical_reads_rnk
          from v$sessmetric m
          where m.cpu>0 or m.PHYSICAL_READS>0
)
select 
    to_char(begin_time,'hh24:mi:ss')
  ||' - '
  ||to_char(end_time,'hh24:mi:ss') time_interval
   ,v.seconds
   ,s.sid
   ,s.serial#
   ,s.username
   ,s.osuser
   ,substr(s.action,1,25) action
   ,substr(s.module,1,30) module
   ,s.sql_id
     ,nvl2( pe.owner
           ,pe.owner
            ||'.'||pe.OBJECT_NAME
            ||nvl2(pe.PROCEDURE_NAME,'.'||pe.PROCEDURE_NAME,'')
           ,''
          )                                        as pe_object
     ,nvl2( po.owner
           ,po.owner
            ||'.'||po.OBJECT_NAME
            ||nvl2(po.PROCEDURE_NAME,'.'||po.PROCEDURE_NAME,'')
           ,null
          )                                        as po_object
   ,cpu
   ,physical_reads
   ,logical_reads
   ,pga_memory
   ,hard_parses
   ,soft_parses
   ,physical_read_pct
   ,logical_read_pct
&_IF_ORA11_OR_HIGHER     ,to_char(s.sql_exec_start,'dd/mm hh24:mi:ss')   as sql_exec_start
from  v
     ,v$session s
     ,dba_procedures pe
     ,dba_procedures po
where v.sid     = s.sid
  and v.serial# = s.serial#
  and pe.OBJECT_ID    (+)    = s.PLSQL_ENTRY_OBJECT_ID
  and pe.SUBPROGRAM_ID(+)    = s.PLSQL_ENTRY_SUBPROGRAM_ID
  and po.OBJECT_ID    (+)    = s.PLSQL_OBJECT_ID
  and po.SUBPROGRAM_ID(+)    = s.PLSQL_SUBPROGRAM_ID
  and(   v.cpu_rnk           <=10
      or v.phy_reads_rnk     <=10
      or v.logical_reads_rnk <= 10
     )
order by 
      cpu_rnk
     ,phy_reads_rnk
     ,logical_reads_rnk
/
col time_interval       clear;
col username            clear;
col osuser              clear;
col action              clear;
col module              clear;
col sql_exec_start      clear;
col PHYSICAL_READS      clear;
col PHYSICAL_READ_PCT   clear;
col LOGICAL_READ_PCT    clear;
col PE_OBJECT           clear;
col PO_OBJECT           clear;
@inc/input_vars_undef;
