col beg_time       format a16;
col PARAMETER_NAME format a50;
col PREV_VALUE     format a30;
col VALUE          format a30;
with v as (
            select--+ leading(sn p) use_nl(p) no_merge
                p.dbid
               ,p.snap_id
               ,to_char(sn.beg_time,'yyyy-mm-dd hh24:mi') beg_time
               --,sn.end_time
               ,p.instance_number    as inst_id
               --,p.parameter_hash
               ,p.parameter_name
               ,lag(p.value) over(partition by p.dbid,p.instance_number,p.parameter_name order by p.snap_id) prev_value
               ,p.value
               ,p.isdefault
               ,p.ismodified
            from 
                  (select--+ no_merge
                          snap_id
                         ,begin_interval_time beg_time
                         ,end_interval_time   end_time
                   from dba_hist_snapshot
                   where end_interval_time > systimestamp - interval '1' month 
                  ) sn
                 ,dba_hist_parameter p
            where p.dbid in (select/*+ precompute_subquery */ dbid from v$database)
              and p.instance_number in (select/*+ precompute_subquery */ vi.INSTANCE_NUMBER from v$instance vi)
              and p.snap_id = sn.snap_id
)
select *
from v
where value!=prev_value
order by parameter_name,snap_id
/
col beg_time       clear;
col PARAMETER_NAME clear;
col PREV_VALUE     clear;
col VALUE          clear;
