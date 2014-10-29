create or replace package xt_stats_utils as

   function raw_to_num(i_raw raw)
      return varchar2 deterministic;
     
   function raw_to_date(i_raw raw)
      return date deterministic;
     
   function raw_to_varchar2(i_raw raw)
      return varchar2 deterministic;
   
   function val_to_output(p_datatype varchar2,p_value raw) 
      return varchar2 deterministic;

   function xrpad(str1 in varchar2,len int,pad varchar2)
      return varchar2 deterministic;

end xt_stats_utils;
/
