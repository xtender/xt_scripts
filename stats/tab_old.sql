@inc/input_vars_init.sql

define tab_owner="nvl(upper('&2'),'%')"
define tab_name="&1"

------------- table stats -------------------
select
    t.owner
   ,t.table_name
   ,t.NUM_ROWS
   ,t.BLOCKS
   ,t.LAST_ANALYZED 
from dba_tables t 
where  
      t.owner      like &tab_owner
  and t.table_name = upper('&tab_name');
------------ indexes stats ------------------
select 
    ix.owner
   ,ix.index_name
   ,ix.num_rows
   ,ix.distinct_keys
   ,ix.blevel
   ,ix.leaf_blocks
   ,ix.last_analyzed 
from dba_indexes ix 
where 
      ix.table_owner like &tab_owner
  and ix.table_name  = upper('&tab_name');
------------- col statistics -----------------
set serverout on;

declare
   
   l_column_name    constant number := 30;
   l_num_distinct   constant number := 12;
   l_low_value      constant number := 18;
   l_high_value     constant number := 18;
   --l_density        constant number := 10;
   l_num_nulls      constant number := 10;
   l_num_buckets    constant number := 10;
   l_last_analyzed  constant number := 20;
   l_sample_size    constant number := 11;
   l_global_stats   constant number := 5 ;
   l_user_stats     constant number := 5 ;
   l_avg_col_len    constant number := 5 ;
   l_histogram      constant number := 20;
   
   full_len         constant number := 25
                                       + l_column_name + l_num_distinct + l_low_value + l_high_value 
                                       -- + l_density
                                       + l_num_nulls + l_num_buckets + l_last_analyzed + l_sample_size 
                                       + l_global_stats + l_user_stats + l_avg_col_len + l_histogram
                                       ;
   function raw_to_num(i_raw raw)
   return varchar2
   as
      m_n varchar2(32000);
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   exception when others then return 'ERROR:'||sqlerrm;
   end;
     
   function raw_to_date(i_raw raw)
   return date
   as
      m_n date;
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   end;
     
   function raw_to_varchar2(i_raw raw)
   return varchar2
   as
      m_n varchar2(4000);
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   end;
   
   function val_to_output(p_datatype varchar2,p_value raw) 
   return varchar2
   is
   begin
      return
        case p_datatype
           when 'VARCHAR2' then raw_to_varchar2(p_value)
           when 'DATE'     then to_char(raw_to_date(p_value),'yyyy-mm-dd hh24:mi:ss')
           when 'NUMBER'   then raw_to_num(p_value)
           when 'FLOAT'    then raw_to_num(p_value)
           else 'tp='||p_datatype
        end;
   end;

begin
   dbms_output.put_line( rpad('-',full_len,'-'));
   dbms_output.put_line( '| '
      ||rpad('column_name'                                 ,l_column_name   ,' ') ||'| '
      ||rpad('num_distinct'                                ,l_num_distinct  ,' ') ||'| '
      ||rpad('low_value'                                   ,l_low_value     ,' ') ||'| '
      ||rpad('high_value'                                  ,l_high_value    ,' ') ||'| '
      --||rpad('density'                                     ,l_density       ,' ') ||'| '
      ||rpad('num_nulls'                                   ,l_num_nulls     ,' ') ||'| '
      ||rpad('num_buckets'                                 ,l_num_buckets   ,' ') ||'| '
      ||rpad('last_analyzed'                               ,l_last_analyzed ,' ') ||'| '
      ||rpad('sample_size'                                 ,l_sample_size   ,' ') ||'| '
      ||rpad('global_stats'                                ,l_global_stats  ,' ') ||'| '
      ||rpad('user_stats'                                  ,l_user_stats    ,' ') ||'| '
      ||rpad('avg_col_len'                                 ,l_avg_col_len   ,' ') ||'| '
      ||rpad('histogram'                                   ,l_histogram     ,' ') ||'| '
      );
   dbms_output.put_line( rpad('-',full_len,'-'));
   
   for r in (
         select 
             cs.column_name
            ,cs.num_distinct
            ,tc.DATA_TYPE
            ,cs.low_value
            ,cs.high_value
            ,cs.density
            ,cs.num_nulls
            ,cs.num_buckets
            ,cs.last_analyzed
            ,cs.sample_size
            ,cs.global_stats
            ,cs.user_stats
            ,cs.avg_col_len
            ,cs.HISTOGRAM
         from dba_tab_col_statistics cs 
             ,dba_tab_columns tc
         where 
                cs.owner      like &tab_owner
            and cs.table_name = upper('&tab_name')
            and tc.OWNER=cs.owner
            and tc.TABLE_NAME=cs.table_name
            and tc.COLUMN_NAME=cs.column_name
   )
   loop
      dbms_output.put_line( '| '
         ||rpad(r.column_name                                 ,l_column_name   ,' ') ||'| '
         ||rpad(r.num_distinct                                ,l_num_distinct  ,' ') ||'| '
         ||rpad(val_to_output(r.data_type,r.low_value)        ,l_low_value     ,' ') ||'| '
         ||rpad(val_to_output(r.data_type,r.high_value)       ,l_high_value    ,' ') ||'| '
         --||rpad(r.density                                     ,l_density       ,' ') ||'| '
         ||rpad(r.num_nulls                                   ,l_num_nulls     ,' ') ||'| '
         ||rpad(r.num_buckets                                 ,l_num_buckets   ,' ') ||'| '
         ||rpad(to_char(r.last_analyzed,'yyyy-mm-dd hh24:mi') ,l_last_analyzed ,' ') ||'| '
         ||rpad(r.sample_size                                 ,l_sample_size   ,' ') ||'| '
         ||rpad(r.global_stats                                ,l_global_stats  ,' ') ||'| '
         ||rpad(r.user_stats                                  ,l_user_stats    ,' ') ||'| '
         ||rpad(r.avg_col_len                                 ,l_avg_col_len   ,' ') ||'| '
         ||rpad(r.histogram                                   ,l_histogram     ,' ') ||'| '
         );
    end loop;
   dbms_output.put_line( rpad('-',full_len,'-'));
end;
/

@inc/input_vars_undef.sql