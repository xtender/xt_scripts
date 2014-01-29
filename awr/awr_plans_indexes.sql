/*
alter session set db_file_multiblock_read_count=256;
create index SYS.IX_WRH$_SQL_PLAN_OBJ# on SYS.WRH$_SQL_PLAN(OBJECT#)                       tablespace ... online;
create index SYS.IX_WRH$_SQL_PLAN_OWNER_OBJ on SYS.WRH$_SQL_PLAN(OBJECT_OWNER,OBJECT_NAME) tablespace ... online;
*/
with t_indexes as (
     select--+ materialize
        i.index_name
       ,o.object_id
       ,sg.BYTES
     from dba_indexes i
         ,dba_objects o
         ,dba_segments sg
     where  
           i.owner         = '&tab_owner'
       and i.table_name    = '&tab_name'
       and i.table_owner   = 'OD'
       and i.owner         = o.owner
       and i.index_name    = o.object_name
       and i.owner         = sg.owner
       and i.index_name    = sg.segment_name
       and sg.segment_type = 'INDEX'
)
select--+ leading(t)
       t.index_name
      ,t.bytes
      ,sum(st.executions_delta)           executions
      ,sum(st.buffer_gets_delta)          buf_gets
      ,sum(st.Physical_Read_Bytes_Delta)  phy_reads
      ,sum(st.elapsed_time_delta)/1e6     ela_time
from 
     t_indexes t
    ,dba_hist_sql_plan p
    ,dba_hist_sqltext  s
    ,sys.wrm$_snapshot sn
    ,sys.wrh$_sqlstat  st
    ,v$database db
where 
      p.OBJECT#               = t.object_id

  and s.sql_id                = p.sql_id
  and s.dbid                  = db.dbid

  and sn.dbid                 = db.dbid
  and sn.begin_interval_time >= trunc(sysdate)-14

  and st.SQL_ID               = p.sql_id
  and st.DBID                 = db.dbid
  and st.SNAP_ID              = sn.snap_id
  and st.INSTANCE_NUMBER      = 1
 
group by 
      t.index_name, t.bytes
order by 
      ela_time desc
/
