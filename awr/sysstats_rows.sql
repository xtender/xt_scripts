with v as (
   select--+ leading(db sn st) use_nl(sn) use_nl(st) no_merge
          st.snap_id
         ,sn.begin_interval_time                                                  as beg_time
         ,to_char(begin_interval_time,'fmday')                                      as wd
         ,st.stat_name
         ,st.value  - lag(value) over(partition by stat_name order by sn.snap_id) as value
         ,lag(sn.snap_id) over(partition by stat_name order by sn.snap_id)             as prev_snap
   from 
        v$database db
       ,dba_hist_snapshot sn 
       ,dba_hist_sysstat st 
   where st.stat_name in (
                  'CPU used by this session'
                 ,'user I/O wait time'
                 ,'DB time'
--                 ,'table scan rows gotten'
--                 ,'rows fetched via callback'
--                 ,'table fetch by rowid'
--                 ,'table fetch continued row'
--                 ,'index fetch by key'
                 )
    and db.DBID    = st.dbid
    and st.snap_id = sn.snap_id
    and sn.dbid    = db.dbid
    and sn.end_interval_time>trunc(sysdate)-365
)              
,v2 as (
    select snap_id,beg_time,wd,stat_name,value,prev_snap
          ,ntile(20) over(partition by stat_name order by value) nt
    from v
    where value       > 0
    and prev_snap + 1 = snap_id
    and extract( hour from beg_time) in (10,11,12)
    and wd not in ('saturday','sunday')
)
,v3 as (
    select snap_id,beg_time,wd,stat_name,value,prev_snap
    from v2
    where snap_id not in ( select snap_id 
                           from v2
                           group by snap_id
                           having sum(decode(nt,1,1,20,1))>=2
                         )
)
select 
      snap_id
     ,to_char(beg_time,'yyyy-mm-dd hh24:mi')          beg_time
     ,wd
     ,to_char(cpu_time             ,'fm999999999999') cpu_time
     ,to_char(io_time              ,'fm999999999999') io_time
     ,to_char(db_time              ,'fm999999999999') db_time
--     ,to_char(fts_rows             ,'999g999g999999') fts_rows
--     ,to_char(fetches_callback     ,'999g999g999999') fetches_callback    
--     ,to_char(fetches_rowid        ,'999g999g999999') fetches_rowid
--     ,to_char(fetches_continued    ,'999g999g999999') fetches_continued
--     ,to_char(fetches_index_by_key ,'999g999g999999') fetches_index_by_key
     ,to_char(round(cpu_time            *100/max(cpu_time            )over(),2),'999.00') pct_cpu_time
     ,to_char(round(io_time             *100/max(io_time             )over(),2),'999.00') pct_io_time
     ,to_char(round(db_time             *100/max(db_time             )over(),2),'999.00') pct_db_time
--     ,to_char(round(fts_rows            *100/max(fts_rows            )over(),2),'999.00') pct_fts_rows
--     ,to_char(round(fetches_callback    *100/max(fetches_callback    )over(),2),'999.00') pct_fetches_callback    
--     ,to_char(round(fetches_rowid       *100/max(fetches_rowid       )over(),2),'999.00') pct_fetches_rowid       
--     ,to_char(round(fetches_continued   *100/max(fetches_continued   )over(),2),'999.00') pct_fetches_continued   
--     ,to_char(round(fetches_index_by_key*100/max(fetches_index_by_key)over(),2),'999.00') pct_fetches_index_by_key
from v3
pivot(
     max(value)
     for stat_name in (
                  'CPU used by this session'   cpu_time
                 ,'user I/O wait time'         io_time
                 ,'DB time'                    db_time
--                 ,'table scan rows gotten'     fts_rows
--                 ,'rows fetched via callback'  fetches_callback
--                 ,'table fetch by rowid'       fetches_rowid
--                 ,'table fetch continued row'  fetches_continued
--                 ,'index fetch by key'         fetches_index_by_key
                 )
)
order by 1
/
