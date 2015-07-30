col dbid            new_val _awr_dbid;
col db_name         for a20;
col beg_time        new_val _beg_time noprint;
col end_time        new_val _end_time noprint;
col version         for a12;
col instance_name   for a20;
col host_name       for a30;
col platform_name   for a30;
col last_startup    for a19;

select 
                        dbid, db_name, version, instance_name, host_name
&_IF_ORA11_OR_HIGHER   ,platform_name
                       ,to_char(startup_time,'yyyy-mm-dd hh24:mi:ss')     as last_startup
                       ,to_char(trunc(sysdate-7       ),'yyyy-mm-dd hh24:mi:ss') as beg_time
                       ,to_char(trunc(sysdate  ,'hh24'),'yyyy-mm-dd hh24:mi:ss') as end_time
from (
      select 
        dense_rank()over(partition by dbid,db_name order by startup_time desc) n
       ,i.*
      from dba_hist_database_instance i
)
where n=1
order by startup_time;

col dbid            clear;
col db_name         clear;
col beg_time        clear;
col end_time        clear;
col version         clear;
col instance_name   clear;
col host_name       clear;
col platform_name   clear;
col last_startup    clear;

accept _awr_dbid  prompt "Enter DBID[&_awr_dbid]: " default '&_awr_dbid';
accept _inst_id   prompt "Instance #[1]: "          default 1;
accept _beg_time  prompt "Begin time[&_beg_time]: " default '&_beg_time';
accept _end_time  prompt "End   time[&_end_time]: " default '&_end_time';
accept _hh_beg    prompt "Begin hour [10]: "        default 10;
accept _hh_end    prompt "End   hour [18]: "        default 18;
accept _topn      prompt "Top N [10] : "            default 10;
accept _awr_except_wday prompt "Except week days[sunday,saturday]: " default "sunday,saturday";
--------------------------
col beg_time new_val beg_time noprint;
col snap_id  new_val snap_id  noprint;
col tsname   for a30;
col filename for a80;

break on beg_time on snap_id skip page;
ttitle -
   '###############################################################################' skip 1 -
   '    Begin time:   ' beg_time skip 1 -
   '    SNAP_ID   :   ' snap_id  skip 1 -
   '###############################################################################' skip 1 -
   '' skip 1;

with 
snaps as (
   select dbid,snap_id,instance_number
         ,begin_interval_time as beg_time
         ,end_interval_time   as end_time
   from dba_hist_snapshot
   where 
        dbid = &_awr_dbid
    and instance_number = &_inst_id
    and end_interval_time   >= timestamp'&_beg_time' - interval '1' hour
    and begin_interval_time <= timestamp'&_end_time'
)
,filestatxs as (
   select 
       sn.beg_time
      ,sn.end_time
      ,fx.snap_id
      ,fx.dbid
      ,fx.file#
      ,fx.creation_change#
      ,fx.filename
      ,fx.ts#
      ,fx.tsname
      ,fx.block_size
      ,decode(fx.snap_id - lag(fx.snap_id)over(partition by file#,filename order by fx.snap_id) , 1 , fx.phyrds         - lag(fx.phyrds        )over(partition by file#,filename order by fx.snap_id)) phyrds        
      ,decode(fx.snap_id - lag(fx.snap_id)over(partition by file#,filename order by fx.snap_id) , 1 , fx.phywrts        - lag(fx.phywrts       )over(partition by file#,filename order by fx.snap_id)) phywrts
      ,decode(fx.snap_id - lag(fx.snap_id)over(partition by file#,filename order by fx.snap_id) , 1 , fx.singleblkrds   - lag(fx.singleblkrds  )over(partition by file#,filename order by fx.snap_id)) singleblkrds
      ,decode(fx.snap_id - lag(fx.snap_id)over(partition by file#,filename order by fx.snap_id) , 1 , fx.readtim        - lag(fx.readtim       )over(partition by file#,filename order by fx.snap_id)) readtim
      ,decode(fx.snap_id - lag(fx.snap_id)over(partition by file#,filename order by fx.snap_id) , 1 , fx.writetim       - lag(fx.writetim      )over(partition by file#,filename order by fx.snap_id)) writetim
      ,decode(fx.snap_id - lag(fx.snap_id)over(partition by file#,filename order by fx.snap_id) , 1 , fx.singleblkrdtim - lag(fx.singleblkrdtim)over(partition by file#,filename order by fx.snap_id)) singleblkrdtim
      ,decode(fx.snap_id - lag(fx.snap_id)over(partition by file#,filename order by fx.snap_id) , 1 , fx.phyblkrd       - lag(fx.phyblkrd      )over(partition by file#,filename order by fx.snap_id)) phyblkrd
      ,decode(fx.snap_id - lag(fx.snap_id)over(partition by file#,filename order by fx.snap_id) , 1 , fx.phyblkwrt      - lag(fx.phyblkwrt     )over(partition by file#,filename order by fx.snap_id)) phyblkwrt
      ,decode(fx.snap_id - lag(fx.snap_id)over(partition by file#,filename order by fx.snap_id) , 1 , fx.wait_count     - lag(fx.wait_count    )over(partition by file#,filename order by fx.snap_id)) wait_count
      ,decode(fx.snap_id - lag(fx.snap_id)over(partition by file#,filename order by fx.snap_id) , 1 , fx.time           - lag(fx.time          )over(partition by file#,filename order by fx.snap_id)) time
   from snaps sn
       ,dba_hist_filestatxs fx
   where fx.dbid                 = sn.dbid
     and fx.snap_id              = sn.snap_id
     and fx.instance_number      = sn.instance_number
)
,filestats as (
   select
       row_number()over(partition by f.snap_id order by f.phyrds       desc) rnk_rds
      ,row_number()over(partition by f.snap_id order by f.phywrts      desc) rnk_wrts
      ,row_number()over(partition by f.snap_id order by f.singleblkrds desc) rnk_srds
      ,f.*
   from filestatxs f
   where 1=1
     and f.phyrds is not null
     and extract(hour from beg_time) between &_hh_beg and &_hh_end
     and (q'[&_awr_except_wday]' is null or q'[&_awr_except_wday]' not like to_char(beg_time,'"%"fmday"%"'))
)
select 
   to_char(beg_time,'yyyy-mm-dd hh24:mi') beg_time
  ,snap_id
  ,rnk_phyrds      
  ,rnk_phywrts
  ,rnk_singleblkrds
  ,file#
  ,filename
  ,tsname
  ,phyrds        
  ,phywrts
  ,singleblkrds
  ,readtim
  ,writetim
  ,singleblkrdtim
  ,phyblkrd
  ,phyblkwrt
  ,wait_count
  ,time
from filestats
where 
   rnk_rds  <= &_topn
or rnk_wrts <= &_topn
or rnk_srds <= &_topn
order by snap_id desc
         ,rnk_phyrds         
         ,rnk_phywrts
         ,rnk_singleblkrds
--        ,phyrds  desc
--        ,phywrts desc
/
ttitle off;
clear break;
clear col;
undef _awr_dbid;
undef _inst_id ;
undef _beg_time;
undef _end_time;
undef _hh_beg  ;
undef _hh_end  ;
undef _topn    ;
undef beg_time;
undef snap_id;
