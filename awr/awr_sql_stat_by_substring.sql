@inc/input_vars_init;

with awr_hist_sql as (
                        select--+ materialize
                            * 
                        from sys.WRH$_SQLTEXT s
                        where upper(s.sql_text) like upper('&1')
--                        and rownum>0
                     )
,awr_hist_sqlstat as (
                        select--+ materialize no_merge(t1) leading(t1 sn t2) use_hash (t1 sn) use_nl(t2) index(t2 WRH$_SQLSTAT_PK)
                            t1.dbid   as dbid_orig
                           ,t1.sql_id as sql_id_orig
                           ,t1.sql_text
                           ,t1.command_type
                           ,t2.*
                        from
                            awr_hist_sql t1
                           ,sys.wrm$_snapshot sn
                           ,sys.wrh$_sqlstat t2
                        where 
                              sn.dbid               = t1.dbid
                          and sn.end_interval_time  > nvl2('&2',to_date('&2','yyyy-mm-dd'),trunc(sysdate)-14)
                          and t2.sql_id             = t1.sql_id
                          and t2.dbid               = t1.dbid
                          and t2.instance_number    = 1
                          and t2.snap_id            = sn.snap_id
                  )
,stat_ordered as (
                        select--+ no_merge(st)
                            sql_id
                           --,row_number()over(order by sum(st.executions_total) desc) rn
                           ,sum(st.executions_total) sum_executions
                        from AWR_HIST_SQLSTAT st
                        where sql_id is not null and rownum>1
                        group by sql_id
                        order by sum(st.executions_total) desc
)
select--+ all_rows
       sto.* 
--      ,to_char((select sql_text from AWR_HIST_SQLSTAT sti where sti.sql_id=sto.sql_id and rownum=1)) sql_text
from stat_ordered sto
where rownum<20;