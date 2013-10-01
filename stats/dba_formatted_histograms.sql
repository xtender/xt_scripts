prompt Creating view dba_formatted_histograms...;
create or replace view dba_formatted_histograms as
with 
 histgrm1 as (
   select--+ inline merge
      owner                 as owner
     ,table_name            as table_name
     ,column_name           as column_name
     ,endpoint_number       as ep_num
     ,endpoint_value        as ep_val
     ,endpoint_actual_value as ep_act_val
     ,lag(endpoint_number)  over(partition by owner,table_name,column_name order by endpoint_number) as ep_num_prev
     ,max(endpoint_number)  over(partition by owner,table_name,column_name)                          as max_ep_num
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
     ,ep_num_prev                 as ep_num_prev
     ,max_ep_num                  as max_ep_num
     ,ep_num - nvl(ep_num_prev,0) as bkt
     ,decode (ep_num - nvl(ep_num_prev,0)
               , 0, 0
               , 1, 0
               , 1
             ) as popularity

   from 
      histgrm1 h
)
select--+ use_nl(st h) leading(st h) push_pred(h)
   st.owner                    as owner
  ,st.table_name               as table_name
  ,st.column_name              as column_name
  ,st.data_type                as data_type
  ,st.num_distinct             as NDV
  ,st.num_buckets              as num_buckets
  ,h.max_ep_num                as max_ep_num
  ,st.density                  as density
  ,st.histogram                as histogram
  ,h.ep_num                    as ep_num
  ,h.ep_val                    as ep_val
  ,h.ep_act_val                as ep_act_val
  ,h.ep_num_prev               as ep_num_prev
  ,h.bkt                       as bkt
  ,h.popularity                as popularity
from
   dba_tab_columns st
  ,histgrm2 h
  ,dba_tables t
where st.owner       = h.owner
  and st.table_name  = h.table_name
  and st.column_name = h.column_name
  and st.owner       = t.owner
  and st.table_name  = t.table_name
;
prompt Creating public synonym dba_formatted_histograms...;
create or replace public synonym dba_formatted_histograms for dba_formatted_histograms;

