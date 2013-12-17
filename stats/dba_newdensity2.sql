create or replace view dba_newdensity as
with
 histgrm1 as (
   select--+ inline merge
      owner                 as owner
     ,table_name            as table_name
     ,column_name           as column_name
     ,endpoint_number       as ep_num
     ,endpoint_value        as ep_val
     ,endpoint_actual_value as ep_act_val
     ,lag(endpoint_number) over(partition by owner,table_name,column_name order by endpoint_number) as ep_num_prev
   from
      dba_histograms h1
)
,histgrm2 as (
   select--+ inline
      owner                       as owner
     ,table_name                  as table_name
     ,column_name                 as column_name
     ,ep_num                      as ep_num
     ,ep_val                      as ep_val
     ,ep_act_val                  as ep_act_val
     ,ep_num - nvl(ep_num_prev,0) as bkt
     ,decode (ep_num - nvl(ep_num_prev,0)
               , 0, 0
               , 1, 0
               , 1
             ) as popularity
   from
      histgrm1 h
)
,hist_agg as (
   select--+ inline
       owner
      ,table_name
      ,column_name
      ,max(ep_num) as BktCnt -- should be equal to sum(bkt)
      ,sum(decode(popularity, 1, bkt,0))  as PopBktCnt
      ,sum(decode(popularity, 1, 1  ,0))  as PopValCnt
--      ,min(bkt) keep(dense_rank first order by decode(popularity,1,ep_num)) as bkt_least_popular_value
--      ,min(decode(popularity,1,bkt)) keep(dense_rank first order by decode(popularity,1,bkt) nulls last) as bkt_least_popular_value
      ,min(decode(popularity,1,bkt)) as bkt_least_popular_value
   from histgrm2
   group by owner,table_name,column_name
)
select
    st.owner
   ,st.table_name
   ,st.column_name
   ,st.histogram
   ,h.BktCnt
   ,h.PopBktCnt
   ,h.PopValCnt
   ,st.num_distinct as NDV
   ,h.bkt_least_popular_value
   ,st.density      as old_Density
   ,case st.histogram
      when 'FREQUENCY'
           then  -- 0.5 * bkt_least_popular_value / t.num_rows
                 0.5 * bkt_least_popular_value / BktCnt
      when 'HEIGHT BALANCED'
           then   ( 1 - PopBktCnt / BktCnt ) / (st.num_distinct - PopValCnt)
    end as newdensity
from
     dba_tab_col_statistics st
    ,hist_agg   h
    ,dba_tables t
where
      st.owner       = h.owner
  and st.table_name  = h.table_name
  and st.column_name = h.column_name
  and st.owner       = t.owner
  and st.table_name  = t.table_name;
