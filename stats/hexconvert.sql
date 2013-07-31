prompt &_C_RED *** Convert hex value to VARCHAR2/DATE/TIMESTAMP/NUMBER/FLOAT *** &_C_RESET
prompt Syntax: @hexconvert DATATYPE HEXVALUE
set serverout on
declare
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
      res := case p_datatype
           when 'VARCHAR2' then raw_to_varchar2(p_value)
           when 'DATE'     then to_char(raw_to_date(p_value),'yyyy-mm-dd hh24:mi:ss')
           when 'TIMESTAMP'     then to_char(raw_to_date(p_value),'yyyy-mm-dd hh24:mi:ss')
           when 'NUMBER'   then raw_to_num(p_value)
           when 'FLOAT'    then raw_to_num(p_value)
           else 'wrong type ='||p_datatype
        end;
      return nvl(res,'NULL');
   end;
   
begin
   dbms_output.put_line(val_to_output(upper('&1'),hextoraw('&2')));
end;
/
set serverout off
undef 1 2
