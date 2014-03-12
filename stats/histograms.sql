prompt Histograms by owner/table/column_name
prompt Syntax 1: @histograms owner table column
prompt Syntax 2: @histograms table column
@inc/input_vars_init
col owner                   format a25
col table_name              format a30
col column_name             format a30
col endpoint_actual_value   format a50
col ep_value                format a39
col data_type               format a25
select 
     h.owner
   , h.table_name
   , h.column_name
   , c.data_type
   , case 
          when c.data_type='DATE' or c.data_type like 'TIMESTAMP%'
               then to_char(
                         to_date(
                                to_char(h.endpoint_value,'FM99999999') 
                                || '.' 
                                || to_char(86400 * mod(h.endpoint_value,1),'FM99999')
                              ,'J.sssss'
                              )
                         )
          when c.data_type in ('FLOAT','NUMBER')
               then to_char(endpoint_value,'tm9')
          when c.data_type in ('CHAR','VARCHAR2','NVARCHAR2')
               then 'use histograms_xml instead'
          else 'unsupporteed'
     end as ep_value
   , h.endpoint_value
   , h.endpoint_value  - lag(h.endpoint_value ,1,0) over(partition by h.owner,h.table_name,h.column_name order by h.endpoint_value) as delta_values
   , h.endpoint_number
   , h.endpoint_number - lag(h.endpoint_number,1,0) over(partition by h.owner,h.table_name,h.column_name order by h.endpoint_value) as delta_numbers
   , h.endpoint_actual_value
from 
     dba_tab_histograms h
   , dba_tab_columns c
where 
     h.owner       like nvl2('&3',upper('&1'),'%')
 and h.table_name  =    nvl2('&3',upper('&2'),upper('&1'))
 and h.column_name like nvl2('&3',upper('&3'),upper('&2'))
 and h.owner       = c.owner(+)
 and h.table_name  = c.table_name(+)
 and h.column_name = c.column_name(+)
order by  h.owner
        , h.table_name
        , h.column_name
        , c.data_type
        , h.endpoint_number
/
col owner                   clear;
col table_name              clear;
col column_name             clear;
col endpoint_actual_value   clear;
col ep_value                clear;
col data_type               clear;
@inc/input_vars_undef;
