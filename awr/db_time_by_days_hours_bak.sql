select distinct i.dbid, i.db_name
from dba_hist_database_instance i;

col dt_day for a25;
accept _awr_db_name prompt "Enter db_name: ";

with
 dbids as (
  select distinct i.dbid, i.db_name
  from dba_hist_database_instance i
  where upper(db_name) like upper('&_awr_db_name')
 )
,snaps as (
  select dbids.db_name, sn.dbid, sn.snap_id, sn.begin_interval_time as beg_time
  from dbids, dba_hist_snapshot sn
  where dbids.dbid = sn.dbid
    and sn.instance_number = 1
)
,db_time as (
select s.db_name,s.beg_time,s.snap_id
      ,round(stm.value - case when s.snap_id - lag(s.snap_id)over(order by s.snap_id) = 1
                              then lag(stm.value)over(order by s.snap_id) 
                         end
            )/1e6 as delta
      ,stm.value
from snaps s
    ,DBA_HIST_SYS_TIME_MODEL stm
where 1=1
  and stm.dbid            = s.dbid
  and stm.snap_id         = s.snap_id
  and stm.instance_number = 1
  and stat_name           = 'DB time'
                          --'DB CPU'
order by s.snap_id desc
)
select
  db_name
 ,to_char(beg_time,'yyyy-mm-dd day') dt_day
 ,min(snap_id) snap_min
 ,max(snap_id) snap_max
-- ,max(decode(to_char(beg_time,'hh24'),'00',delta)) d_00
-- ,max(decode(to_char(beg_time,'hh24'),'01',delta)) d_01
-- ,max(decode(to_char(beg_time,'hh24'),'02',delta)) d_02
-- ,max(decode(to_char(beg_time,'hh24'),'03',delta)) d_03
-- ,max(decode(to_char(beg_time,'hh24'),'04',delta)) d_04
-- ,max(decode(to_char(beg_time,'hh24'),'05',delta)) d_05
-- ,max(decode(to_char(beg_time,'hh24'),'06',delta)) d_06
-- ,max(decode(to_char(beg_time,'hh24'),'07',delta)) d_07
-- ,max(decode(to_char(beg_time,'hh24'),'08',delta)) d_08
-- ,max(decode(to_char(beg_time,'hh24'),'09',delta)) d_09
 ,max(decode(to_char(beg_time,'hh24'),'10',delta)) d_10
 ,max(decode(to_char(beg_time,'hh24'),'11',delta)) d_11
 ,max(decode(to_char(beg_time,'hh24'),'12',delta)) d_12
 ,max(decode(to_char(beg_time,'hh24'),'13',delta)) d_13
 ,max(decode(to_char(beg_time,'hh24'),'14',delta)) d_14
 ,max(decode(to_char(beg_time,'hh24'),'15',delta)) d_15
 ,max(decode(to_char(beg_time,'hh24'),'16',delta)) d_16
 ,max(decode(to_char(beg_time,'hh24'),'17',delta)) d_17
-- ,max(decode(to_char(beg_time,'hh24'),'18',delta)) d_18
-- ,max(decode(to_char(beg_time,'hh24'),'19',delta)) d_19
-- ,max(decode(to_char(beg_time,'hh24'),'20',delta)) d_20
-- ,max(decode(to_char(beg_time,'hh24'),'21',delta)) d_21
-- ,max(decode(to_char(beg_time,'hh24'),'22',delta)) d_22
-- ,max(decode(to_char(beg_time,'hh24'),'23',delta)) d_23
from db_time
group by db_name,to_char(beg_time,'yyyy-mm-dd day')
order by 2
/
col dt_day clear;
