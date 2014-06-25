set serverout on;
prompt "Only first 50 values will be printed."
accept tab_name prompt "Table name: ";
accept col_name prompt "Col name: ";
accept max_count prompt "Max number distinct values to show[50]: " default 50;
declare
   v_tab_name varchar2(30):='&tab_name';
   v_col_name varchar2(30):='&col_name';
   v_curr     varchar2(4000);
   v_cnt      int:=0;

   function f_get_next(
               p_tab_name varchar2
              ,p_col_name varchar2
              ,p_curr_val varchar2 default null
   )
   return varchar2
   is
      res varchar2(4000);
   begin
      if p_curr_val is null 
         then
            execute immediate 
               utl_lms.format_message(
                  'select min("%s") from %s where "%s" is not null'
                  ,p_col_name
                  ,p_tab_name
                  ,p_col_name
               )
               into res;
         else
            execute immediate 
               utl_lms.format_message(
                  q'[select min("%s") from %s where "%s" > '%s']'
                  ,p_col_name
                  ,p_tab_name
                  ,p_col_name
                  ,p_curr_val
               )
               into res;
      end if;
      return res;
   end;
begin
   loop
      v_curr:=f_get_next(v_tab_name,v_col_name,v_curr);
      exit when v_curr is null;
      if v_cnt<=&max_count then dbms_output.put_line(v_curr); end if;
      v_cnt:=v_cnt+1;
   end loop;
   dbms_output.put_line('Overall count: '||v_cnt);
end;
/
undef tab_name col_name max_count;
set serverout off;