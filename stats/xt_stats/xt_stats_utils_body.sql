create or replace package body xt_stats_utils as

   l_table_name     constant number := 30;
   l_column_name    constant number := 30;
   l_num_rows       constant number := 12;
   l_num_distinct   constant number := 12;
   l_low_value      constant number := 30;
   l_high_value     constant number := 30;
   l_density        constant number := 10;
   l_num_nulls      constant number := 10;
   l_num_buckets    constant number := 10;
   l_last_analyzed  constant number := 20;
   l_sample_size    constant number := 11;
   l_global_stats   constant number := 5 ;
   l_user_stats     constant number := 5 ;
   l_avg_col_len    constant number := 5 ;
   l_histogram      constant number := 20;

   function raw_to_num(i_raw raw)
      return varchar2 deterministic
   as
      m_n number;
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   exception when others then return 'ERROR:'||sqlerrm;
   end;
     
   function raw_to_date(i_raw raw)
      return date deterministic
   as
      m_n date;
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   end;
     
   function raw_to_varchar2(i_raw raw)
      return varchar2 deterministic
   as
      m_n varchar2(4000);
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   end;
   
   function val_to_output(p_datatype varchar2,p_value raw) 
      return varchar2 deterministic
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
      return varchar2 deterministic
   is
      str2 varchar2(32676):=nvl(replace(str1,chr(10),' '),' ');
   begin
      --str2:=regexp_replace(str2,'[[:cntrl:]]','~');
      if regexp_like(str2,'[[:cntrl:]]') then 
         select 'DUMP:'||dump(str2,17) into str2 from dual;
      end if;
      return rpad(str2,len,pad);
   end;
end xt_stats_utils;
/
