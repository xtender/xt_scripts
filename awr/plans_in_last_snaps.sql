with last_snaps as (
     select dbid, snap_id, begin_interval_time, inst_id
     from (select dbid, snap_id, begin_interval_time, instance_number as inst_id
           from SYS.WRM$_SNAPSHOT sn
           order by sn.begin_interval_time desc)
     where rownum<=30
)
select 
       ls.*
      ,st.sql_id
      ,pl.*
from last_snaps ls
    ,SYS.WRH$_SQLSTAT st
    ,dba_hist_sql_plan pl
where 
      ls.dbid    = st.dbid
  and ls.snap_id = st.snap_id
  and ls.inst_id = st.instance_number
  and st.dbid    = pl.dbid
  and st.sql_id  = pl.sql_id;