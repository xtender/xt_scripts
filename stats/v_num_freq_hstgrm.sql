create view v_num_freq_hstgrm as 
      select 
          owner
        , table_name
        , column_name
        , low_value
        , high_value
        , begpoint_number
        , endpoint_number
        , begpoint_value
        , endpoint_value
        , notnulls_rows
        , round(          100*(endpoint_number-begpoint_number)/lastpoint_number,5) as est_PCT
        , round(notnulls_rows*(endpoint_number-begpoint_number)/lastpoint_number)   as est_num_rows
      from (
         select c.owner
               ,c.table_name
               ,c.column_name
               ,c.num_nulls
               ,h.endpoint_number
               ,h.endpoint_value
               ,utl_raw.cast_to_number(c.low_value)  as low_value
               ,utl_raw.cast_to_number(c.high_value) as high_value
               ,(select num_rows from dba_tables t where t.owner = c.owner and t.table_name=c.table_name)-num_nulls as notnulls_rows
               ,lag(h.endpoint_number,1,1) over(partition by c.owner, c.table_name, c.column_name order by h.endpoint_number)  as begpoint_number
               ,lag(h.endpoint_value ,1,utl_raw.cast_to_number(c.low_value)) over(partition by c.owner, c.table_name, c.column_name order by h.endpoint_number)  as begpoint_value
               ,max(h.endpoint_number)     over(partition by c.owner, c.table_name, c.column_name)  lastpoint_number
         from 
            dba_tab_columns c
           ,dba_tab_histograms h
         where 
                c.owner       = h.owner
            and c.table_name  = h.table_name
            and c.column_name = h.column_name
            and c.histogram   = 'FREQUENCY'
            and c.data_type   = 'NUMBER'
      )
/
