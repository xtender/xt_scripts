col db_name          new_val _awr_db_name;
col awr_db_beg_date  new_val _awr_db_beg_date noprint;
select distinct i.dbid, i.db_name
     , to_char(trunc(sysdate-30,'mm'),'yyyy-mm-dd') as awr_db_beg_date
from dba_hist_database_instance i;

col dt_day for a25;
accept _awr_db_name     prompt "Enter db_name[&_awr_db_name]: "  default "&_awr_db_name";
accept _awr_db_beg_date prompt "Start date[&_awr_db_beg_date]: " default "&_awr_db_beg_date";
accept _awr_db_beg_hour prompt "Start hour[10]: " default 10;
accept _awr_db_end_hour prompt "End hour[18]: "   default 18;

def _frm_len = 15;

col cols new_val _cols noprint;

select to_char(wm_concat(cols)) cols
 from (
      select  'd_'||to_char(hh,'fm00')
             ||
             ',f_'||to_char(hh,'fm00')
              cols
      from (select level-1 hh from dual connect by level<=24)
      where hh between &_awr_db_beg_hour and &_awr_db_end_hour
);

col f_00 for a&_frm_len;
col f_01 for a&_frm_len;
col f_02 for a&_frm_len;
col f_03 for a&_frm_len;
col f_04 for a&_frm_len;
col f_05 for a&_frm_len;
col f_06 for a&_frm_len;
col f_07 for a&_frm_len;
col f_08 for a&_frm_len;
col f_09 for a&_frm_len;
col f_10 for a&_frm_len;
col f_11 for a&_frm_len;
col f_12 for a&_frm_len;
col f_13 for a&_frm_len;
col f_14 for a&_frm_len;
col f_15 for a&_frm_len;
col f_16 for a&_frm_len;
col f_17 for a&_frm_len;
col f_18 for a&_frm_len;
col f_19 for a&_frm_len;
col f_20 for a&_frm_len;
col f_21 for a&_frm_len;
col f_22 for a&_frm_len;
col f_23 for a&_frm_len;


with
 dbids as (
    select distinct i.dbid, i.db_name
    from dba_hist_database_instance i
    where upper(db_name) like upper('&_awr_db_name')
 )
,snaps as (
    select dbids.db_name, sn.dbid, sn.snap_id
         , sn.begin_interval_time as beg_time
         , sn.end_interval_time   as end_time
         , extract(hour from sn.begin_interval_time) beg_hh
         , extract(hour from sn.end_interval_time)   end_hh
    from dbids, dba_hist_snapshot sn
    where dbids.dbid = sn.dbid
      and sn.instance_number = 1
      and sn.end_interval_time>date'&_awr_db_beg_date'
)
,db_time as (
    select 
       v_db_time.*
      ,max(delta) over() max_delta
    from (
       select--+ leading(s stm) no_merge(stm) use_hash(stm) no_merge
              s.db_name
             ,s.beg_time
             ,s.end_time
             ,s.beg_hh
             ,s.end_hh
             ,s.snap_id
             ,round((
                     stm.value - case when s.snap_id - lag(s.snap_id)over(order by s.snap_id) = 1
                                     then lag(stm.value)over(order by s.snap_id) 
                                end
                    )/1e6
                   ) as delta
             ,stm.value
       from snaps s
           ,DBA_HIST_SYS_TIME_MODEL stm
       where 1=1
         and stm.dbid            = s.dbid
         and stm.snap_id         = s.snap_id
         and stm.instance_number = 1
         and stm.stat_name       = 'DB time'
                                 --'DB CPU'
    order by s.snap_id desc
    ) v_db_time
    where end_hh >= &_awr_db_beg_hour
      and beg_hh <= &_awr_db_end_hour
)
,db_time_hh as (
    select
        db_name
       ,to_char(beg_time,'yyyy-mm-dd day') dt_day
       ,min(snap_id)                       snap_min
       ,max(snap_id)                       snap_max
       ,max(max_delta)                     max_delta
       ,max(decode(beg_hh, 00, delta)) d_00
       ,max(decode(beg_hh, 01, delta)) d_01
       ,max(decode(beg_hh, 02, delta)) d_02
       ,max(decode(beg_hh, 03, delta)) d_03
       ,max(decode(beg_hh, 04, delta)) d_04
       ,max(decode(beg_hh, 05, delta)) d_05
       ,max(decode(beg_hh, 06, delta)) d_06
       ,max(decode(beg_hh, 07, delta)) d_07
       ,max(decode(beg_hh, 08, delta)) d_08
       ,max(decode(beg_hh, 09, delta)) d_09
       ,max(decode(beg_hh, 10, delta)) d_10
       ,max(decode(beg_hh, 11, delta)) d_11
       ,max(decode(beg_hh, 12, delta)) d_12
       ,max(decode(beg_hh, 13, delta)) d_13
       ,max(decode(beg_hh, 14, delta)) d_14
       ,max(decode(beg_hh, 15, delta)) d_15
       ,max(decode(beg_hh, 16, delta)) d_16
       ,max(decode(beg_hh, 17, delta)) d_17
       ,max(decode(beg_hh, 18, delta)) d_18
       ,max(decode(beg_hh, 19, delta)) d_19
       ,max(decode(beg_hh, 20, delta)) d_20
       ,max(decode(beg_hh, 21, delta)) d_21
       ,max(decode(beg_hh, 22, delta)) d_22
       ,max(decode(beg_hh, 23, delta)) d_23
   from db_time
   group by db_name,to_char(beg_time,'yyyy-mm-dd day')
)
,formatted as (
   select hh.* 
         ,rpad('|' , 1+ceil(d_00*(&_frm_len-1)/max_delta),'#') f_00
         ,rpad('|' , 1+ceil(d_01*(&_frm_len-1)/max_delta),'#') f_01
         ,rpad('|' , 1+ceil(d_02*(&_frm_len-1)/max_delta),'#') f_02
         ,rpad('|' , 1+ceil(d_03*(&_frm_len-1)/max_delta),'#') f_03
         ,rpad('|' , 1+ceil(d_04*(&_frm_len-1)/max_delta),'#') f_04
         ,rpad('|' , 1+ceil(d_05*(&_frm_len-1)/max_delta),'#') f_05
         ,rpad('|' , 1+ceil(d_06*(&_frm_len-1)/max_delta),'#') f_06
         ,rpad('|' , 1+ceil(d_07*(&_frm_len-1)/max_delta),'#') f_07
         ,rpad('|' , 1+ceil(d_08*(&_frm_len-1)/max_delta),'#') f_08
         ,rpad('|' , 1+ceil(d_09*(&_frm_len-1)/max_delta),'#') f_09
         ,rpad('|' , 1+ceil(d_10*(&_frm_len-1)/max_delta),'#') f_10
         ,rpad('|' , 1+ceil(d_11*(&_frm_len-1)/max_delta),'#') f_11
         ,rpad('|' , 1+ceil(d_12*(&_frm_len-1)/max_delta),'#') f_12
         ,rpad('|' , 1+ceil(d_13*(&_frm_len-1)/max_delta),'#') f_13
         ,rpad('|' , 1+ceil(d_14*(&_frm_len-1)/max_delta),'#') f_14
         ,rpad('|' , 1+ceil(d_15*(&_frm_len-1)/max_delta),'#') f_15
         ,rpad('|' , 1+ceil(d_16*(&_frm_len-1)/max_delta),'#') f_16
         ,rpad('|' , 1+ceil(d_17*(&_frm_len-1)/max_delta),'#') f_17
         ,rpad('|' , 1+ceil(d_18*(&_frm_len-1)/max_delta),'#') f_18
         ,rpad('|' , 1+ceil(d_19*(&_frm_len-1)/max_delta),'#') f_19
         ,rpad('|' , 1+ceil(d_20*(&_frm_len-1)/max_delta),'#') f_20
         ,rpad('|' , 1+ceil(d_21*(&_frm_len-1)/max_delta),'#') f_21
         ,rpad('|' , 1+ceil(d_22*(&_frm_len-1)/max_delta),'#') f_22
         ,rpad('|' , 1+ceil(d_23*(&_frm_len-1)/max_delta),'#') f_23
   from db_time_hh hh
)
select
  db_name,dt_day,snap_min,snap_max
  ,&_cols
from formatted
order by 2
/
col dt_day clear;

undef _cols _frm_len _awr_db_name _awr_db_beg_date _awr_db_beg_hour _awr_db_end_hour;
clear col;
clear bre;

