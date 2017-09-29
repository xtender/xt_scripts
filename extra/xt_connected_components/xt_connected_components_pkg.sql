create or replace package XT_CONNECTED_COMPONENTS is

  -- Author  : Sayan Malakshinov
  v_size     constant integer := 100;
  fetch_size constant integer:=1000;
  
  /**
   * Function get_strings - returns connected components found from cursor.
   * @param cur - Input cursor. Should contain one Varchar2 column with linked strings, for example: 'a,b,c'
   * @param delim - List delimiter. Default: ','
   * @return Pipelined table of varchar2(v_size)
   * Examples:
    1) select * from table(xt_connected_components.get_strings( cursor(select ELEM1||','||ELEM2 from TEST));
    2) select * 
       from
         table(
           xt_connected_components.get_strings( 
              cursor(select 'a,b,c' from dual union all
                     select 'd,e,f' from dual union all
                     select 'e,c'   from dual union all
                     select 'z'     from dual union all
                     select 'X,Y'   from dual union all
                     select 'Y,Z'   from dual)));
   */
  function get_strings(cur in sys_refcursor, delim varchar2:=',') return strings_array pipelined;
  
  /**
   * Function get_numbers - returns connected components found from cursor.
   * @param cur - Input cursor. Should contain TWO columns with linked numbers.
   * @return Pipelined table of NUMBER
   * Examples:
    1) select * from table(xt_connected_components.get_numbers( cursor(select sender_id, recipient_id from messages));
    2) select * 
       from
         table(
           xt_connected_components.get_numbers( 
              cursor(select level account1, level*2 account2 from dual connect by level<=10)));
   */
  function get_numbers(cur in sys_refcursor) return numbers_array pipelined;

end XT_CONNECTED_COMPONENTS;
/