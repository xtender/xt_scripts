@inc/input_vars_init.sql


prompt &_C_RED Show column statistics by partitions &_C_RESET;
accept _tab_owner prompt "Table owner[&_USER]: " default &_USER;
accept _tab_mask  prompt "Table name(or mask): ";
   col owner        for a30;
   col table_name   new_val _tab_name;
   col partitioned  for a11;
   select t.OWNER
        , t.TABLE_NAME
        , t.PARTITIONED
   from dba_tables t
   where t.owner      =    upper('&_tab_owner')
     and t.table_name like upper('&_tab_mask')
     and t.partitioned = 'YES'
   order by 1,2;
   col table_name clear;
accept _tab_name  prompt "Confirm table name[&_tab_name]: " default &_tab_name;
   
   
   select column_id
        , column_name 
   from dba_tab_columns c 
   where c.owner      = upper('&_tab_owner') 
     and c.table_name = '&_tab_name'
   order by c.column_id;
accept _col_mask  prompt "Columns mask[%]    : " default %;

   col part_name  for a30;
   col high_value for a120;
   select p.partition_position as "#"
         ,p.partition_name     as part_name
         ,p.subpartition_count as subparts
         ,p.num_rows
         ,p.blocks
         ,p.empty_blocks
         ,p.last_analyzed
         ,p.user_stats 
         ,p.high_value
   from dba_tab_partitions p
   where p.table_owner = upper('&_tab_owner') 
     and p.table_name  = '&_tab_name'
   order by p.partition_position;
   col part_name  clear;
   col high_value clear;
accept _part_mask prompt "Partition mask[%]  : " default %;
prompt ------------- col stats   -----------------;
set serverout on;

declare
   
   l_column_name    constant number := 30;
   l_part_name      constant number := 20;
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
                                       + l_column_name + l_part_name + l_num_distinct + l_low_value + l_high_value 
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
      ||rpad('part_name'                                   ,l_part_name     ,' ') ||'| '
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
             tc.column_name
            ,cs.partition_name as part_name
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
         from dba_part_col_statistics cs 
             ,dba_tab_columns tc
             ,dba_tab_partitions p
         where 
                tc.owner          = upper('&_tab_owner')
            and tc.table_name     = '&_tab_name'
            and tc.column_name    like upper('&_col_mask')
            
            and p.table_owner     = upper('&_tab_owner')
            and p.table_name      = '&_tab_name'
            and p.partition_name  like upper('&_part_mask')
            
            and p.table_owner     = cs.owner
            and p.table_name      = cs.table_name
            and p.partition_name  = cs.partition_name

            and tc.OWNER          = cs.owner
            and tc.TABLE_NAME     = cs.table_name
            and tc.COLUMN_NAME    = cs.column_name
         order by tc.column_id, p.partition_position
   )
   loop
      dbms_output.put_line( '| '
         ||xrpad(r.column_name                                 ,l_column_name   ,' ') ||'| '
         ||xrpad(r.part_name                                   ,l_part_name     ,' ') ||'| '
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
undef tab_name tab_owner _tab_name _tab_owner _tab_mask _col_mask;
@inc/input_vars_undef.sql
