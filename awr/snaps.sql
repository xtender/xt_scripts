col snap_n              for a12;
col STARTUP_TIME        for a16;
col BEGIN_INTERVAL      for a16;
col END_INTERVAL        for a16;
col SNAP_TIMEZONE       for a13;
select
       lpad(to_char(rnk1,'tm9'),length(to_char(cnt,'tm9')),' ')||' / '||cnt  as snap_n
      ,SNAP_ID
      ,DBID
      ,INSTANCE_NUMBER  inst_id
      ,to_char(STARTUP_TIME       ,'yyyy-mm-dd hh24:mi') STARTUP_TIME
      ,to_char(BEGIN_INTERVAL_TIME,'yyyy-mm-dd hh24:mi') BEGIN_INTERVAL
      ,to_char(END_INTERVAL_TIME  ,'yyyy-mm-dd hh24:mi') END_INTERVAL
--      ,FLUSH_ELAPSED
      ,SNAP_LEVEL
      ,ERROR_COUNT
      ,SNAP_FLAG
      ,SNAP_TIMEZONE
from 
   (select 
       SNAP_ID
      ,DBID
      ,INSTANCE_NUMBER
      ,STARTUP_TIME
      ,BEGIN_INTERVAL_TIME
      ,END_INTERVAL_TIME
      ,FLUSH_ELAPSED
      ,SNAP_LEVEL
      ,ERROR_COUNT
      ,SNAP_FLAG
      ,SNAP_TIMEZONE
      ,row_number() over(partition by dbid order by snap_id  asc) rnk1
      ,row_number() over(partition by dbid order by snap_id desc) rnk1_desc
      ,count(*) over() cnt
   from dba_hist_snapshot sn
   ) v
where 
    (rnk1<=5 or rnk1_desc<=5)
order by snap_id
/
col snap_n              clear;
col STARTUP_TIME        clear;
col BEGIN_INTERVAL      clear;
col END_INTERVAL        clear;
col SNAP_TIMEZONE       clear;