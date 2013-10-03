prompt Histograms by owner/table/column_name
prompt Syntax 1: @histograms owner table column
prompt Syntax 2: @histograms table column
@inc/input_vars_init
col tab                    format a35
col col                    format a30
--col endpoint_value         format a39
col endpoint_actual_value  format a50
col data_type              format a20
var cur_out refcursor;
------------------------------------------------
------------------------------------------------
declare
   
   v_ep1    varchar2(100);
   xdata    xmltype; 
   xdetail  clob;
   x_ep     clob;
     
   /** converting functions   */
   function xml_enquote(p_vc varchar2) return varchar2
   is
     r_vc varchar2(4000):=null;
     cN   char(1);
   begin
      for i in 1..length(p_vc) loop
         cN:=substr(p_vc,i,1);
         r_vc:=r_vc||case 
                       when ascii(cn)<32 then '&#'||ascii(cN)||';'
                       else cN
                     end;
      end loop;
      return r_vc;
   end;
   -- date and timestamp converting functions(w/o fractional seconds):
   function hist_datetochar(
      p_num number
   ) return varchar2
   is
   begin
      return to_char(
                    to_date(
                          to_char(p_num,'FM99999999')|| '.' || to_char(86400 * mod(p_num,1),'FM99999')
                        ,'J.sssss'
                        )
                   ,'YYYY-MM-DD hh24:mi:ss'
                   );
   end;
   
   /** decrypting chars based on functions by Martin Widlake:  */
   -- http://mwidlake.wordpress.com/2009/08/11/decrypting-histogram-data/
   function hist_chartonum(
      p_vc    varchar2
     ,p_trunc varchar2 :='Y'
   ) return number
   is
      m_vc varchar2(15) := substr(rpad(p_vc,15,chr(0)),1,15);
      m_n number := 0;
   begin
      for i in 1..15 loop
        m_n := m_n + power(256,15-i) * ascii(substr(m_vc,i,1));
      end loop;
   -- this converts it from a 36 digit number to the 15-digit number used
   -- in the ENDPOINT_VALUE Column.
      If p_trunc = 'Y' then
         m_n := round(m_n, -21);
      end if;
      return m_n;
   end;
    
   function hist_numtochar(
      p_num   number
     ,p_trunc varchar2 :='Y'
   ) return varchar2
   is
      m_vc   varchar2(15);
      m_n    number :=0;
      m_n1   number;
      m_loop number :=7;
   begin
      m_n :=p_num;
      if length(to_char(m_n))<36 then
         m_vc:='num format err';
      else
         if p_trunc !='Y' then
            m_loop :=15;
         end if;

         for i in 1..m_loop loop
            m_n1:=trunc(m_n/(power(256,15-i)));
            if m_n1!=0 then 
               m_vc:=m_vc||chr(m_n1);
            end if;
            m_n:=m_n-(m_n1*power(256,15-i));  
         end loop;
      end if;
      return m_vc;
   end;

   function hist_numtochar2(
      p_num   number
     ,p_trunc varchar2 :='Y'
   ) return varchar2
   is
      m_vc   varchar2(15);
      m_n    number :=0;
      m_n1   number;
      m_loop number :=7;
   begin
      m_n :=p_num;
      if length(to_char(m_n))<36 then
         m_vc:='num format err';
      else
         if p_trunc !='Y' then
            m_loop :=15;
         else
            m_n:=m_n+power(256,9);
         end if;
         --dbms_output.put_line(to_char(m_N,'999,999,999,999,999,999,999,999,999,999,999,999'));
         for i in 1..m_loop loop
            m_n1 := trunc(m_n/(power(256,15-i)));
            if m_n1!=0 then 
               m_vc := m_vc||chr(m_n1);
            end if;
            m_n := m_n-(m_n1*power(256,15-i));
         end loop;
      end if;
      return m_vc;
   end;
   -- end functions
begin
   /** get xmlaggregated histograms */
   with t_histogram as (
         select     h.owner                                       as owner
                  , h.table_name                                  as table_name
                  , h.owner||'.'||h.table_name                    as tab
                  , h.column_name                                 as col
                  , c.data_type                                   as data_type
                  , h.endpoint_value                              as endpoint_value
                  , lag(h.endpoint_value) 
                       over(
                          partition by 
                             h.owner
                            ,h.table_name
                            ,h.column_name 
                          order by h.endpoint_value
                          )                                       as endpoint_value_prev
                  , h.endpoint_value  
                    - lag(h.endpoint_value) 
                        over( 
                          partition by 
                             h.owner
                            ,h.table_name
                            ,h.column_name 
                          order by h.endpoint_value
                          )                                       as delta_values
                  , h.endpoint_number                             as endpoint_number
                  , h.endpoint_number 
                    - lag(h.endpoint_number)
                        over( 
                          partition by 
                             h.owner
                            ,h.table_name
                            ,h.column_name 
                          order by h.endpoint_value
                          )                                       as delta_numbers
                  , h.endpoint_actual_value                       as endpoint_actual_value
                  -- lengths for formatting:
                  , max(length(h.owner||'.'||h.table_name))over() as l_tab
                  , max(length(h.column_name))             over() as l_col
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
   ) -- end with
   select
      xmlagg(
         xmlelement(
              "HISTOGRAM"
             ,xmlattributes(tab,col,data_type,endpoint_value,endpoint_value_prev,delta_values,endpoint_number,delta_numbers,endpoint_actual_value)
            )
         order by 
              owner
            , table_name
            , col
            , endpoint_value
      )
      into xdata
   from t_histogram;
   /* end select */  
   --/*
   -- details:
   xdetail:='<DETAILS>';
   for r in (
           select * 
           from xmltable('$X/HISTOGRAM                     '
                         passing xdata as "X"
                         columns 
                           tab                    varchar2(100) path '@TAB'
                          ,col                    varchar2(30)  path '@COL'
                          ,data_type              varchar2(30)  path '@DATA_TYPE'
                          ,endpoint_value         number        path '@ENDPOINT_VALUE'
                          ,endpoint_value_prev    number        path '@ENDPOINT_VALUE_PREV'
                          ,delta_values           number        path '@DELTA_VALUES'
                          ,endpoint_number        number        path '@ENDPOINT_NUMBER'
                          ,delta_numbers          number        path '@DELTA_NUMBERS'
                          ,endpoint_actual_value  varchar2(1000)path '@ENDPOINT_ACTUAL_VALUE'
                        )
      )
   loop
      v_ep1 := 
               case
                  when r.data_type = 'DATE' or r.data_type like 'TIMESTAMP%'
                     then hist_datetochar( r.endpoint_value)
                  when r.data_type in ('FLOAT','NUMBER')
                     then to_char( r.endpoint_value,'tm9')
                  when r.data_type in ('CHAR','VARCHAR2','NVARCHAR2')
                     then hist_numtochar ( r.endpoint_value  )
                  else 
                        'unsupported'
               end;
      --dbms_output.put_line(v_ep1);
      
      xdetail:=xdetail||'<DETAIL '
                         ||' TAB="'||r.tab||'"'
                         ||' COL="'||r.col||'"'
                         ||' ENDPOINT_NUMBER="'||to_char(r.ENDPOINT_NUMBER,'TM9')||'"'
                         ||' ENDPOINT_VALUE="'||to_char(r.endpoint_value,'TM9')||'"'
                         ||'> <EP1><![CDATA['||xml_enquote(v_ep1)||']]></EP1>"'
                      ||' </DETAIL>'||chr(10);
   end loop;
   xdetail:=xdetail||'</DETAILS>';
   -- end details
   --*/
   /*
   open :cur_out 
   for q'[
           select * 
           from xmltable('$X/HISTOGRAM                     '
                         passing :xdata as "X"
                         columns 
                           tab                    varchar2(100)   path '@TAB'
                          ,col                    varchar2(30)    path '@COL'
                          ,data_type              varchar2(30)    path '@DATA_TYPE'
                          ,endpoint_value         number          path '@ENDPOINT_VALUE'
                          ,endpoint_value_prev    number          path '@ENDPOINT_VALUE_PREV'
                          ,delta_values           number          path '@DELTA_VALUES'
                          ,endpoint_number        number          path '@ENDPOINT_NUMBER'
                          ,delta_numbers          number          path '@DELTA_NUMBERS'
                          ,endpoint_actual_value  varchar2(1000)  path '@ENDPOINT_ACTUAL_VALUE'
                        )
       ]' using xdata;
--   */
/*
   open :cur_out 
   --for 'select * from dual';/*
   for q'[
           select * 
           from xmltable('$XD/DETAILS/DETAIL'
                         passing xmltype(:xdetail) as "XD"
                         columns 
                           tab                    varchar2(100) path '@TAB'
                          ,col                    varchar2(30)  path '@COL'
                          ,endpoint_value         number        path '@ENDPOINT_VALUE'
                          ,ep1                    varchar2(100) path 'EP1'
                        )
          where rownum<10
       ]' using xdetail;
--*/

   open :cur_out 
   --for 'select * from dual';/*
   for q'[ with xdata as (
                 select/*+ no_merge materialize */ * 
                 from xmltable('$X/HISTOGRAM                     '
                               passing :xdata as "X"
                               columns 
                                 tab                    varchar2(100)   path '@TAB'
                                ,col                    varchar2(30)    path '@COL'
                                ,data_type              varchar2(30)    path '@DATA_TYPE'
                                ,endpoint_value         varchar2(30)          path '@ENDPOINT_VALUE'
                                ,endpoint_value_prev    number          path '@ENDPOINT_VALUE_PREV'
                                ,delta_values           number          path '@DELTA_VALUES'
                                ,endpoint_number        number          path '@ENDPOINT_NUMBER'
                                ,delta_numbers          number          path '@DELTA_NUMBERS'
                                ,endpoint_actual_value  varchar2(1000)  path '@ENDPOINT_ACTUAL_VALUE'
                              )
           ), xdetail as (
                 select/*+ no_merge materialize */ * 
                 from xmltable('$XD/DETAILS/DETAIL'
                               passing xmltype(:xdetail) as "XD"
                               columns 
                                 tab                    varchar2(100) path '@TAB'
                                ,col                    varchar2(30)  path '@COL'
                                ,endpoint_number        number        path '@ENDPOINT_NUMBER'
                                ,endpoint_value         varchar2(30)  path '@ENDPOINT_VALUE'
                                ,ep1                    varchar2(100) path 'EP1'
                              )
          )
          select--+ NO_XML_QUERY_REWRITE
                xdata.tab
               ,xdata.col
               ,xdata.data_type            
               ,xdata.endpoint_number      
               ,xdata.endpoint_actual_value
               ,xdetail.EP1
               ,xdata.endpoint_value       
               ,xdata.endpoint_value_prev  
               ,xdata.delta_values         
               ,xdata.delta_numbers        
          from xdata,xdetail
          where xdata.tab          = xdetail.tab
          and xdata.col            = xdetail.col
          --and xdata.endpoint_value = xdetail.endpoint_value
          and xdata.endpoint_number = xdetail.endpoint_number
          --where rownum<10
       ]' using xdata,xdetail;
end;
/
print cur_out;
col tab                    clear;
col col                    clear;
--col endpoint_value         clear;
col endpoint_actual_value  clear;
col data_type              clear;

@inc/input_vars_undef;
