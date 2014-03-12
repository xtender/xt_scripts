@inc/input_vars_init.sql

define tab_owner="nvl(upper('&2'),'%')"
define tab_name="&1"

col owner           for a15
col table_name      for a30
col partition_name  for a20
col index_name      for a30
col st_lock         for a7
col #               for 999
------------- table stats -------------------
select
    t.owner
   ,t.table_name
   ,t.PARTITION_NAME
   ,t.PARTITION_POSITION as "#"
   ,t.stattype_locked as st_lock
   ,t.stale_stats
   ,t.global_stats
   ,t.user_stats
   ,t.NUM_ROWS
   ,t.BLOCKS
   ,t.EMPTY_BLOCKS
   ,t.AVG_ROW_LEN
   ,t.AVG_SPACE
   ,t.LAST_ANALYZED 
from dba_tab_statistics t 
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
   ,ix.clustering_factor as cl_factor
   ,ix.last_analyzed
   ,ix.global_stats
   ,ix.user_stats
from dba_indexes ix 
where 
      ix.table_owner like &tab_owner
  and ix.table_name  = upper('&tab_name');
------------- col statistics -----------------
set serverout on;

declare
   
   l_column_name    constant number := 30;
   l_num_distinct   constant number := 12;
   l_low_value      constant number := 30;
   l_high_value     constant number := 30;
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
      m_n number;
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
     res varchar2(4000);
   begin
      res := case 
           when p_datatype in ('CHAR','VARCHAR2')                       then raw_to_varchar2(p_value)
           when p_datatype = 'DATE' or p_datatype like 'TIMESTAMP%'     then to_char(raw_to_date(p_value),'yyyy-mm-dd hh24:mi:ss')
           when p_datatype = 'NUMBER'                                   then raw_to_num(p_value)
           when p_datatype = 'FLOAT'                                    then raw_to_num(p_value)
           else 'tp='||p_datatype
        end;
      return nvl(res,'NULL');
   end;

   function xrpad(str1 in varchar2,len int,pad varchar2)
   return varchar2
   is
      str2 varchar2(32676):=nvl(replace(str1,chr(10),' '),' ');
   begin
      --str2:=regexp_replace(str2,'[[:cntrl:]]','~');
      if regexp_like(str2,'[[:cntrl:]]') then 
         select 'DUMP:'||dump(str2,17) into str2 from dual;
      end if;
      return rpad(str2,len,pad);
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
         ||xrpad(r.column_name                                 ,l_column_name   ,' ') ||'| '
         ||xrpad(r.num_distinct                                ,l_num_distinct  ,' ') ||'| '
         ||xrpad(val_to_output(r.data_type,r.low_value)        ,l_low_value     ,' ') ||'| '
         ||xrpad(val_to_output(r.data_type,r.high_value)       ,l_high_value    ,' ') ||'| '
         --||xrpad(r.density                                     ,l_density       ,' ') ||'| '
         ||xrpad(r.num_nulls                                   ,l_num_nulls     ,' ') ||'| '
         ||xrpad(r.num_buckets                                 ,l_num_buckets   ,' ') ||'| '
         ||xrpad(to_char(r.last_analyzed,'yyyy-mm-dd hh24:mi') ,l_last_analyzed ,' ') ||'| '
         ||xrpad(r.sample_size                                 ,l_sample_size   ,' ') ||'| '
         ||xrpad(r.global_stats                                ,l_global_stats  ,' ') ||'| '
         ||xrpad(r.user_stats                                  ,l_user_stats    ,' ') ||'| '
         ||xrpad(r.avg_col_len                                 ,l_avg_col_len   ,' ') ||'| '
         ||xrpad(r.histogram                                   ,l_histogram     ,' ') ||'| '
         );
    end loop;
   dbms_output.put_line( rpad('-',full_len,'-'));
end;
/

@inc/input_vars_undef.sql