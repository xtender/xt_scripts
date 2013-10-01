prompt &_C_REVERSE. *** Histograms by owner/table/column_name with density. &_C_RESET
prompt * Syntax 1: @histograms owner table column
prompt * Syntax 2: @histograms table column

@inc/input_vars_init;
break on num_distinct on num_buckets;
break on owner on table_name on column_name on ndv on num_buckets on density on histogram skip 1;
col owner       format a15;
col table_name  format a20;
col column_name format a20;
col histogram   format a15;
col ep_value    format a15;

select 
       f.owner
      ,f.table_name
      ,f.column_name
      ,ndv
      ,num_buckets
      ,density
      ,histogram
      ,ep_num
      ,ep_num_prev
      ,max_ep_num
      ,ep_val
      ,case 
          when data_type='DATE' or data_type like 'TIMESTAMP%'
               then to_char(
                         to_date(
                                to_char(f.ep_val,'FM99999999') 
                                || '.' 
                                || to_char(86400 * mod(f.ep_val,1),'FM99999')
                              ,'J.sssss'
                              )
                         )
          when f.data_type in ('FLOAT','NUMBER')
               then to_char(ep_val,'tm9')
          when f.data_type in ('CHAR','VARCHAR2','NVARCHAR2')
               then 'use histograms_xml instead'
          else 'unsupporteed'
       end as ep_value
      ,bkt
      ,popularity
      ,case histogram
          when 'FREQUENCY'
             then 0.5 * min(decode(popularity,1,bkt)) over(partition by f.owner,f.table_name,f.column_name) -- bkt(least_popular_value)
                  / s.num_rows
          when 'HEIGHT BALANCED'
             then 
                ( 1 
                   - sum(decode(popularity, 1, bkt,0))over(partition by f.owner,f.table_name,f.column_name) -- PopBktCnt
                      / max_ep_num 
                ) / (NDV - sum(decode(popularity, 1, 1  ,0))over(partition by f.owner,f.table_name,f.column_name)) -- PopValCnt
       end newdensity
/*********/
from dba_formatted_histograms f
    ,dba_tab_statistics s
where 
     f.owner       like nvl2('&3',upper('&1'),'%')
 and f.table_name  =    nvl2('&3',upper('&2'),upper('&1'))
 and f.column_name like nvl2('&3',upper('&3'),nvl(upper('&2'),'%'))
 and s.owner       = f.owner 
 and s.table_name  = f.table_name
order by f.owner,f.table_name,f.column_name,f.ep_num
/
@inc/input_vars_undef;
